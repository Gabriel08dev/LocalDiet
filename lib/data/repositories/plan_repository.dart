import 'package:drift/drift.dart';

import '../../domain/local_date.dart';
import '../../domain/nutrients.dart';
import '../../domain/portion.dart';
import '../../domain/profile_enums.dart';
import '../app_database.dart';
import '../ids.dart';
import '../tables.dart';
import 'diary_repository.dart';

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

/// Quantas refeições do plano foram seguidas ou trocadas em um período.
class PlanAdherence {
  const PlanAdherence({required this.followed, required this.other});

  final int followed;
  final int other;

  int get marked => followed + other;

  /// Fração das refeições marcadas em que o plano foi seguido.
  double? get rate => marked == 0 ? null : followed / marked;
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

  /// O que foi marcado em cada refeição de um dia.
  Stream<Map<MealType, PlanCheckStatus>> watchChecks(LocalDate date) =>
      (_db.select(_db.planChecks)..where((t) => t.date.equalsValue(date)))
          .watch()
          .map((rows) => {for (final row in rows) row.meal: row.status});

  Future<void> _setCheck(
    LocalDate date,
    MealType meal,
    PlanCheckStatus status,
  ) => _db
      .into(_db.planChecks)
      .insertOnConflictUpdate(
        PlanChecksCompanion.insert(
          date: date,
          meal: meal,
          status: status,
          checkedAt: DateTime.now(),
        ),
      );

  /// Marca a refeição como seguida e registra no Diário o que estava
  /// planejado para ela. Devolve os ids dos itens criados.
  ///
  /// As duas coisas acontecem na mesma transação. Os itens entram com o
  /// snapshot atual de cada alimento e podem ser ajustados depois no Diário.
  ///
  /// Se a refeição já está marcada como seguida, não faz nada e devolve uma
  /// lista vazia: um segundo toque não registra os itens em dobro.
  Future<List<String>> followMeal(LocalDate date, MealType meal) =>
      _db.transaction(() async {
        final existing =
            await (_db.select(_db.planChecks)..where(
                  (t) => t.date.equalsValue(date) & t.meal.equalsValue(meal),
                ))
                .getSingleOrNull();
        if (existing?.status == PlanCheckStatus.followed) return const [];

        final query =
            _db.select(_db.planItems).join([
                innerJoin(
                  _db.foods,
                  _db.foods.id.equalsExp(_db.planItems.foodId),
                ),
              ])
              ..where(_db.planItems.meal.equalsValue(meal))
              ..orderBy([OrderingTerm.asc(_db.planItems.position)]);
        final rows = await query.get();
        if (rows.isEmpty) {
          throw StateError('O plano não tem itens para esta refeição');
        }
        final portions = [
          for (final row in rows)
            FoodPortion(
              foodId: row.readTable(_db.foods).id,
              foodName: row.readTable(_db.foods).name,
              per100: row.readTable(_db.foods).per100,
              portion: Portion(
                measureLabel: row.readTable(_db.planItems).measureLabel,
                measureGrams: row.readTable(_db.planItems).measureGrams,
                quantity: row.readTable(_db.planItems).quantity,
              ),
            ),
        ];
        final ids = await DiaryRepository(_db).addItems(date, meal, portions);
        await _setCheck(date, meal, PlanCheckStatus.followed);
        return ids;
      });

  /// Desfaz [followMeal]: tira do Diário os itens criados e a marcação.
  Future<void> undoFollow(
    LocalDate date,
    MealType meal,
    List<String> itemIds,
  ) => _db.transaction(() async {
    await DiaryRepository(_db).deleteItems(itemIds);
    await clearCheck(date, meal);
  });

  /// Marca que, nesta refeição, o usuário comeu outra coisa.
  Future<void> markOther(LocalDate date, MealType meal) =>
      _setCheck(date, meal, PlanCheckStatus.other);

  /// Remove a marcação. O que já está no Diário não muda.
  Future<void> clearCheck(LocalDate date, MealType meal) => (_db.delete(
    _db.planChecks,
  )..where((t) => t.date.equalsValue(date) & t.meal.equalsValue(meal))).go();

  /// Adesão ao plano entre [from] e [to], incluindo os dois dias.
  Stream<PlanAdherence> watchAdherence({
    required LocalDate from,
    required LocalDate to,
  }) =>
      (_db.select(_db.planChecks)
            ..where((t) => t.date.isBetweenValues(from.toIso(), to.toIso())))
          .watch()
          .map(
            (rows) => PlanAdherence(
              followed: rows
                  .where((row) => row.status == PlanCheckStatus.followed)
                  .length,
              other: rows
                  .where((row) => row.status == PlanCheckStatus.other)
                  .length,
            ),
          );
}
