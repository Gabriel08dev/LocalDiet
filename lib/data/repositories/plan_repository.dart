import 'package:drift/drift.dart';

import '../../domain/nutrients.dart';
import '../../domain/portion.dart';
import '../../domain/profile_enums.dart';
import '../app_database.dart';
import '../ids.dart';

/// Um item do Plano Base com o alimento a que se refere.
class PlanEntry {
  const PlanEntry({required this.item, required this.food});

  final PlanItemRow item;
  final FoodRow food;

  /// O Plano olha para a frente, então usa os valores atuais do alimento.
  Nutrients get nutrients => food.per100.forGrams(item.grams);

  /// O alimento foi desativado e o item precisa ser revisto pelo usuário.
  bool get needsReview => !food.isActive;
}

class PlanRepository {
  PlanRepository(this._db);

  final AppDatabase _db;

  Stream<List<PlanEntry>> watchAll() {
    final query =
        _db.select(_db.planItems).join([
          innerJoin(_db.foods, _db.foods.id.equalsExp(_db.planItems.foodId)),
        ])..orderBy([
          OrderingTerm.asc(_db.planItems.position),
          OrderingTerm.asc(_db.planItems.id),
        ]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => PlanEntry(
              item: row.readTable(_db.planItems),
              food: row.readTable(_db.foods),
            ),
          )
          .toList(),
    );
  }

  Future<void> addItems(MealType meal, List<FoodPortion> items) =>
      _db.transaction(() async {
        final max = _db.planItems.position.max();
        final query = _db.selectOnly(_db.planItems)
          ..addColumns([max])
          ..where(_db.planItems.meal.equalsValue(meal));
        final current = await query.map((row) => row.read(max)).getSingle();
        var position = (current ?? -1) + 1;
        for (final item in items) {
          if (!item.portion.isValid || item.foodId == null) {
            throw ArgumentError.value(item.foodName, 'item');
          }
          await _db
              .into(_db.planItems)
              .insert(
                PlanItemsCompanion.insert(
                  id: newId(),
                  meal: meal,
                  position: position++,
                  foodId: item.foodId!,
                  measureLabel: item.portion.measureLabel,
                  measureGrams: item.portion.measureGrams,
                  quantity: item.portion.quantity,
                  grams: item.portion.grams,
                ),
              );
        }
      });

  Future<void> updatePortion(String id, Portion portion) {
    if (!portion.isValid) throw ArgumentError.value(portion.grams, 'grams');
    return (_db.update(_db.planItems)..where((t) => t.id.equals(id))).write(
      PlanItemsCompanion(
        measureLabel: Value(portion.measureLabel),
        measureGrams: Value(portion.measureGrams),
        quantity: Value(portion.quantity),
        grams: Value(portion.grams),
      ),
    );
  }

  Future<void> deleteItem(String id) =>
      (_db.delete(_db.planItems)..where((t) => t.id.equals(id))).go();

  Future<void> restoreItem(PlanItemRow item) =>
      _db.into(_db.planItems).insertOnConflictUpdate(item);
}
