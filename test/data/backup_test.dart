import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/data/app_database.dart';
import 'package:localdiet/data/repositories/backup_repository.dart';
import 'package:localdiet/data/repositories/diary_repository.dart';
import 'package:localdiet/data/repositories/food_repository.dart';
import 'package:localdiet/data/repositories/measure_repository.dart';
import 'package:localdiet/data/repositories/plan_repository.dart';
import 'package:localdiet/data/repositories/profile_repository.dart';
import 'package:localdiet/domain/local_date.dart';
import 'package:localdiet/domain/profile_enums.dart';

import 'support.dart';

const _today = LocalDate(2026, 10, 7);

/// Preenche o banco com um pouco de cada tipo de dado do usuário.
Future<void> _populate(AppDatabase db) async {
  final foods = FoodRepository(db);
  await ProfileRepository(db).completeOnboarding(
    name: 'Gabriel',
    birthDate: const LocalDate(1998, 10, 8),
    sex: Sex.male,
    heightCm: 178,
    goal: Goal.lose,
    activity: ActivityLevel.moderate,
    today: _today,
    weightKg: 82.5,
    waistCm: 90,
    neckCm: 39,
  );
  final wheyId = await foods.saveUserFood(
    name: 'Whey',
    per100: sampleNutrients,
  );
  await MeasureRepository(db)
      .addUserMeasure(foodId: wheyId, label: 'scoop', grams: 30);
  await MeasureRepository(db)
      .addUserMeasure(foodId: riceId, label: 'minha concha', grams: 90);
  final rice = (await foods.byId(riceId))!;
  final whey = (await foods.byId(wheyId))!;
  await DiaryRepository(db).addItems(_today, MealType.lunch, [
    portionOf(rice, 252),
    portionOf(whey, 30),
  ]);
  await DiaryRepository(db)
      .addItems(_today.addDays(-1), MealType.dinner, [portionOf(rice, 100)]);
  await PlanRepository(db).addItems(MealType.breakfast, [portionOf(whey, 30)]);
  await PlanRepository(db).followMeal(_today, MealType.breakfast);
  await PlanRepository(db).markOther(_today, MealType.dinner);
  await foods.setFavorite(riceId, favorite: true);
  await foods.setFavorite(wheyId, favorite: true);
  await SettingsRepository(db).setValue('theme', 'dark');
}

/// Tudo o que é dado do usuário, em forma comparável.
Future<Map<String, Object?>> _userData(AppDatabase db) async {
  Future<List<Map<String, Object?>>> table(String sql) async =>
      (await db.customSelect(sql).get()).map((row) => row.data).toList();
  return {
    'profiles': await table('SELECT * FROM profiles'),
    'body': await table('SELECT * FROM body_measurements ORDER BY id'),
    'foods': await table(
      "SELECT * FROM foods WHERE source = 'user' ORDER BY id",
    ),
    'measures': await table(
      "SELECT * FROM measures WHERE source = 'user' ORDER BY id",
    ),
    'diary': await table('SELECT * FROM diary_items ORDER BY id'),
    'plan': await table('SELECT * FROM plan_items ORDER BY id'),
    'checks': await table('SELECT * FROM plan_checks ORDER BY date, meal'),
    'favorites': await table('SELECT * FROM favorites ORDER BY food_id'),
    'settings': await table('SELECT * FROM settings ORDER BY key'),
  };
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = await databaseWithTaco();
    await _populate(db);
  });

  tearDown(() => db.close());

  test(
    'exportar, apagar o banco e importar reproduz os mesmos dados',
    () async {
      final before = await _userData(db);
      final file = await BackupRepository(db).export();

      final fresh = await databaseWithTaco();
      addTearDown(fresh.close);
      await BackupRepository(fresh).restore(file);

      expect(await _userData(fresh), before);
      expect((await FoodRepository(fresh).search('whey')).single.name, 'Whey');
    },
  );

  test('o arquivo se identifica e não leva a TACO', () async {
    final json =
        jsonDecode(await BackupRepository(db).export()) as Map<String, dynamic>;
    expect(json['format'], backupFormat);
    expect(json['formatVersion'], backupFormatVersion);
    expect(json['schemaVersion'], 2);
    expect(json['planChecks'], hasLength(2));
    expect(DateTime.parse(json['exportedAt'] as String).isUtc, isTrue);
    expect(json['userFoods'], hasLength(1));
    expect(json['userMeasures'], hasLength(2));
    expect(
      (json['diaryItems'] as List).first['date'],
      matches(r'^\d{4}-\d{2}-\d{2}$'),
    );
    expect((json['profile'] as Map)['birthDate'], '1998-10-08');
  });

  test('o resumo descreve o conteúdo sem alterar o banco', () async {
    final backup = BackupRepository(db);
    final summary = backup.inspect(await backup.export());
    expect(summary.hasProfile, isTrue);
    expect(summary.diaryItems, 4);
    expect(summary.diaryDays, 2);
    expect(summary.planItems, 1);
    expect(summary.bodyMeasurements, 1);
    expect(summary.userFoods, 1);
    expect(summary.userMeasures, 2);
    expect(summary.favorites, 2);
    expect(summary.exportedAt, isNotNull);
  });

  test('importar substitui os dados atuais em vez de somar', () async {
    final backup = BackupRepository(db);
    final file = await backup.export();
    await DiaryRepository(db).addItems(_today, MealType.snack, [
      portionOf((await FoodRepository(db).byId(riceId))!, 10),
    ]);
    await FoodRepository(db)
        .saveUserFood(name: 'Zzextra', per100: sampleNutrients);

    await backup.restore(file);
    final data = await _userData(db);
    expect(data['diary'], hasLength(4));
    expect(data['checks'], hasLength(2));
    expect(data['foods'], hasLength(1));
    expect(await FoodRepository(db).search('zzextra'), isEmpty);
  });

  group('arquivo recusado não altera nada', () {
    late Map<String, Object?> before;
    late Map<String, dynamic> valid;

    setUp(() async {
      before = await _userData(db);
      valid = jsonDecode(
        await BackupRepository(db).export(),
      ) as Map<String, dynamic>;
    });

    Future<void> expectRejected(String content) async {
      final backup = BackupRepository(db);
      expect(
        () => backup.inspect(content),
        throwsA(isA<BackupFormatException>()),
      );
      await expectLater(
        backup.restore(content),
        throwsA(isA<BackupFormatException>()),
      );
      expect(await _userData(db), before);
    }

    test('texto que não é JSON', () => expectRejected('isto não é um backup'));

    test('JSON de outra origem', () => expectRejected('{"format":"outro"}'));

    test('JSON que não é objeto', () => expectRejected('[1,2,3]'));

    test('versão de formato mais nova que a suportada', () {
      return expectRejected(jsonEncode({...valid, 'formatVersion': 99}));
    });

    test('versão de schema mais nova que a do app', () {
      return expectRejected(jsonEncode({...valid, 'schemaVersion': 99}));
    });

    test('seção ausente', () {
      return expectRejected(jsonEncode(Map.of(valid)..remove('diaryItems')));
    });

    test('linha com campo obrigatório faltando', () {
      final broken = Map<String, dynamic>.of(valid);
      broken['diaryItems'] = [
        Map<String, dynamic>.of(
          (valid['diaryItems'] as List).first as Map<String, dynamic>,
        )..remove('grams'),
      ];
      return expectRejected(jsonEncode(broken));
    });

    test('data inválida em uma linha', () {
      final broken = Map<String, dynamic>.of(valid);
      broken['bodyMeasurements'] = [
        {
          ...(valid['bodyMeasurements'] as List).first as Map<String, dynamic>,
          'date': '07/10/2026',
        },
      ];
      return expectRejected(jsonEncode(broken));
    });

    test('alimento da TACO disfarçado de alimento do usuário', () {
      final broken = Map<String, dynamic>.of(valid);
      broken['userFoods'] = [
        {
          ...(valid['userFoods'] as List).first as Map<String, dynamic>,
          'source': 'taco',
        },
      ];
      return expectRejected(jsonEncode(broken));
    });
  });

  test('backup do schema 1, sem marcações do plano, é aceito', () async {
    final json =
        jsonDecode(await BackupRepository(db).export()) as Map<String, dynamic>;
    json
      ..['schemaVersion'] = 1
      ..remove('planChecks');
    final fresh = await databaseWithTaco();
    addTearDown(fresh.close);
    await BackupRepository(fresh).restore(jsonEncode(json));
    final data = await _userData(fresh);
    expect(data['diary'], hasLength(4));
    expect(data['checks'], isEmpty);
  });

  test('backup do schema 2 sem a seção de marcações é recusado', () async {
    final json =
        jsonDecode(await BackupRepository(db).export()) as Map<String, dynamic>;
    json.remove('planChecks');
    await expectLater(
      BackupRepository(db).restore(jsonEncode(json)),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test(
    'referência a alimento inexistente desfaz a importação inteira',
    () async {
      final before = await _userData(db);
      final json = jsonDecode(
        await BackupRepository(db).export(),
      ) as Map<String, dynamic>;
      json['planItems'] = [
        {
          ...(json['planItems'] as List).first as Map<String, dynamic>,
          'foodId': 'user:nao-existe',
        },
      ];
      await expectLater(
        BackupRepository(db).restore(jsonEncode(json)),
        throwsA(anything),
      );
      expect(await _userData(db), before);
    },
  );
}
