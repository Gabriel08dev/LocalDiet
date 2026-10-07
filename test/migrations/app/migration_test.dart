import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/data/app_database.dart';
import 'package:localdiet/data/repositories/plan_repository.dart';
import 'package:localdiet/domain/local_date.dart';
import 'package:localdiet/domain/profile_enums.dart';

import 'generated/schema.dart';

/// Confere as migrations contra os snapshots de schema em `drift_schemas/`.
///
/// Ao mudar o schema, rode `dart run drift_dev make-migrations`: ele exporta
/// o snapshot da nova versão e regenera `generated/`. Este arquivo é mantido
/// à mão.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('um banco criado do zero tem o schema da versão atual', () async {
    final schema = await verifier.schemaAt(GeneratedHelper.versions.last);
    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, GeneratedHelper.versions.last);
  });

  group('cada versão antiga chega ao schema de cada versão seguinte', () {
    const versions = GeneratedHelper.versions;
    for (final (index, from) in versions.indexed) {
      for (final to in versions.skip(index + 1)) {
        test('da versão $from para a $to', () async {
          final schema = await verifier.schemaAt(from);
          final db = AppDatabase(schema.newConnection());
          addTearDown(db.close);
          await verifier.migrateAndValidate(db, to);
        });
      }
    }
  });

  test('da versão 1 para a 2: os dados do usuário continuam intactos', () async {
    final schema = await verifier.schemaAt(1);
    // Um banco como o do primeiro APK: perfil, medição, alimento e registro.
    schema.rawDatabase
      ..execute(
        "INSERT INTO profiles (id, name, birth_date, sex, height_cm, goal, "
        "activity) VALUES (1, 'Gabriel', '1996-05-15', 'male', 178, 'lose', "
        "'moderate')",
      )
      ..execute(
        "INSERT INTO body_measurements (id, date, weight_kg, created_at) "
        "VALUES ('m1', '2026-10-07', 82.5, 1791000000)",
      )
      ..execute(
        "INSERT INTO foods (id, source, taco_number, name, search_text, kcal, "
        "protein, carb, fat, fiber, sodium, is_active) VALUES ('taco:1', "
        "'taco', 1, 'Arroz, integral, cozido', 'arroz integral cozido', 124, "
        "2.6, 25.8, 1.0, 2.7, 1, 1)",
      )
      ..execute(
        "INSERT INTO diary_items (id, date, meal, position, food_id, "
        "food_name, measure_label, measure_grams, quantity, grams, kcal100, "
        "protein100, carb100, fat100, fiber100, sodium100, created_at) VALUES "
        "('d1', '2026-10-07', 'lunch', 0, 'taco:1', 'Arroz, integral, cozido', "
        "'g', 1, 252, 252, 124, 2.6, 25.8, 1.0, 2.7, 1, 1791000000)",
      )
      ..execute(
        "INSERT INTO plan_items (id, meal, position, food_id, measure_label, "
        "measure_grams, quantity, grams) VALUES ('p1', 'lunch', 0, 'taco:1', "
        "'g', 1, 200, 200)",
      );

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);

    final profile = await db.select(db.profiles).getSingle();
    expect(profile.name, 'Gabriel');
    expect(profile.birthDate, const LocalDate(1996, 5, 15));
    expect(profile.goal, Goal.lose);

    final item = await db.select(db.diaryItems).getSingle();
    expect(item.date, const LocalDate(2026, 10, 7));
    expect(item.nutrients.kcal, closeTo(312.48, 1e-9));
    expect((await db.select(db.bodyMeasurements).getSingle()).weightKg, 82.5);
    expect(await db.select(db.planItems).get(), hasLength(1));
    expect(
      (await db
              .customSelect('SELECT COUNT(*) AS c FROM food_search')
              .getSingle())
          .read<int>('c'),
      1,
    );

    // A tabela nova nasce vazia e já funciona.
    expect(await db.select(db.planChecks).get(), isEmpty);
    await PlanRepository(db)
        .followMeal(const LocalDate(2026, 10, 8), MealType.lunch);
    expect(await db.select(db.planChecks).get(), hasLength(1));
    expect(await db.select(db.diaryItems).get(), hasLength(2));
  });
}
