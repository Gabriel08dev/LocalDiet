import 'package:drift/drift.dart';

import '../app_database.dart';
import '../ids.dart';
import '../tables.dart';

class MeasureRepository {
  MeasureRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$MeasuresTable, MeasureRow> _activeFor(String foodId) =>
      _db.select(_db.measures)
        ..where((t) => t.foodId.equals(foodId) & t.isActive.equals(true))
        ..orderBy([
          // Medidas do sistema primeiro, na ordem do asset.
          (t) => OrderingTerm.asc(t.source),
          (t) => OrderingTerm.asc(t.sortOrder),
          (t) => OrderingTerm.asc(t.label),
        ]);

  Future<List<MeasureRow>> forFood(String foodId) => _activeFor(foodId).get();

  Stream<List<MeasureRow>> watchForFood(String foodId) =>
      _activeFor(foodId).watch();

  /// Salva uma medida do próprio usuário para um alimento.
  Future<String> addUserMeasure({
    required String foodId,
    required String label,
    required double grams,
  }) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(label, 'label');
    if (!grams.isFinite || grams <= 0) {
      throw ArgumentError.value(grams, 'grams');
    }
    final id = 'user:${newId()}';
    await _db
        .into(_db.measures)
        .insert(
          MeasuresCompanion.insert(
            id: id,
            foodId: foodId,
            source: MeasureSource.user,
            label: trimmed,
            grams: grams,
          ),
        );
    return id;
  }

  /// Desativa uma medida do usuário. Registros antigos não são afetados,
  /// porque guardam o rótulo e a gramatura usados.
  Future<void> deactivateUserMeasure(String id) =>
      (_db.update(_db.measures)..where(
            (t) => t.id.equals(id) & t.source.equalsValue(MeasureSource.user),
          ))
          .write(const MeasuresCompanion(isActive: Value(false)));
}
