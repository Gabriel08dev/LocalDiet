import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/data/app_database.dart';

import 'generated/schema.dart';

/// Confere o banco contra os snapshots de schema em `drift_schemas/`.
///
/// Ao criar a versão 2, rode `dart run drift_dev make-migrations`: ele exporta
/// o novo snapshot e gera os testes que partem de um banco real na versão 1.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test(
    'um banco criado do zero tem o schema exportado como versão 1',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 1);
    },
  );

  test('um banco já na versão 1 abre sem alterações', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 1);
  });
}
