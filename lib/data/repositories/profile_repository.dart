import 'package:drift/drift.dart';

import '../../domain/local_date.dart';
import '../../domain/profile_enums.dart';
import '../app_database.dart';
import '../ids.dart';

const _profileId = 1;

class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  Stream<ProfileRow?> watch() => (_db.select(
    _db.profiles,
  )..where((t) => t.id.equals(_profileId))).watchSingleOrNull();

  Future<void> save({
    required String name,
    required LocalDate birthDate,
    required Sex sex,
    required double heightCm,
    required Goal goal,
    required ActivityLevel activity,
    double? manualKcalTarget,
  }) => _db
      .into(_db.profiles)
      .insertOnConflictUpdate(
        ProfilesCompanion.insert(
          id: const Value(_profileId),
          name: name.trim(),
          birthDate: birthDate,
          sex: sex,
          heightCm: heightCm,
          goal: goal,
          activity: activity,
          manualKcalTarget: Value(manualKcalTarget),
        ),
      );

  /// Conclui o onboarding: grava o perfil e a primeira medição corporal em
  /// uma única transação.
  Future<void> completeOnboarding({
    required String name,
    required LocalDate birthDate,
    required Sex sex,
    required double heightCm,
    required Goal goal,
    required ActivityLevel activity,
    required LocalDate today,
    required double weightKg,
    double? waistCm,
    double? neckCm,
    double? hipCm,
  }) => _db.transaction(() async {
    await save(
      name: name,
      birthDate: birthDate,
      sex: sex,
      heightCm: heightCm,
      goal: goal,
      activity: activity,
    );
    await _db
        .into(_db.bodyMeasurements)
        .insert(
          BodyMeasurementsCompanion.insert(
            id: newId(),
            date: today,
            weightKg: Value(weightKg),
            waistCm: Value(waistCm),
            neckCm: Value(neckCm),
            hipCm: Value(hipCm),
            createdAt: DateTime.now(),
          ),
        );
  });
}

class BodyRepository {
  BodyRepository(this._db);

  final AppDatabase _db;

  /// Todas as medições, da mais antiga para a mais recente.
  Stream<List<BodyMeasurementRow>> watchAll() =>
      (_db.select(_db.bodyMeasurements)..orderBy([
            (t) => OrderingTerm.asc(t.date),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
          .watch();

  /// Cria ou atualiza uma medição. Ao menos um valor precisa ser informado.
  Future<void> save({
    String? id,
    required LocalDate date,
    double? weightKg,
    double? waistCm,
    double? neckCm,
    double? hipCm,
  }) async {
    final values = [weightKg, waistCm, neckCm, hipCm];
    if (values.every((value) => value == null)) {
      throw ArgumentError('Medição sem nenhum valor');
    }
    if (values.any(
      (value) => value != null && (!value.isFinite || value <= 0),
    )) {
      throw ArgumentError('Medição com valor inválido');
    }
    if (id == null) {
      await _db
          .into(_db.bodyMeasurements)
          .insert(
            BodyMeasurementsCompanion.insert(
              id: newId(),
              date: date,
              weightKg: Value(weightKg),
              waistCm: Value(waistCm),
              neckCm: Value(neckCm),
              hipCm: Value(hipCm),
              createdAt: DateTime.now(),
            ),
          );
    } else {
      await (_db.update(
        _db.bodyMeasurements,
      )..where((t) => t.id.equals(id))).write(
        BodyMeasurementsCompanion(
          date: Value(date),
          weightKg: Value(weightKg),
          waistCm: Value(waistCm),
          neckCm: Value(neckCm),
          hipCm: Value(hipCm),
        ),
      );
    }
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.bodyMeasurements)..where((t) => t.id.equals(id))).go();

  Future<void> restore(BodyMeasurementRow row) =>
      _db.into(_db.bodyMeasurements).insertOnConflictUpdate(row);
}

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Stream<String?> watchValue(String key) =>
      (_db.select(_db.settings)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value);

  Future<void> setValue(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
}
