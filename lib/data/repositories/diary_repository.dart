import 'package:drift/drift.dart';

import '../../domain/local_date.dart';
import '../../domain/portion.dart';
import '../../domain/profile_enums.dart';
import '../app_database.dart';
import '../ids.dart';

class DiaryRepository {
  DiaryRepository(this._db);

  final AppDatabase _db;

  Stream<List<DiaryItemRow>> watchDay(LocalDate date) =>
      (_db.select(_db.diaryItems)
            ..where((t) => t.date.equalsValue(date))
            ..orderBy([
              (t) => OrderingTerm.asc(t.position),
              (t) => OrderingTerm.asc(t.createdAt),
            ]))
          .watch();

  Future<List<DiaryItemRow>> _mealItems(LocalDate date, MealType meal) =>
      (_db.select(_db.diaryItems)
            ..where((t) => t.date.equalsValue(date) & t.meal.equalsValue(meal))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();

  Future<int> _nextPosition(LocalDate date, MealType meal) async {
    final max = _db.diaryItems.position.max();
    final query = _db.selectOnly(_db.diaryItems)
      ..addColumns([max])
      ..where(
        _db.diaryItems.date.equalsValue(date) &
            _db.diaryItems.meal.equalsValue(meal),
      );
    final current = await query.map((row) => row.read(max)).getSingle();
    return (current ?? -1) + 1;
  }

  /// Registra os itens de uma refeição.
  ///
  /// A gravação é uma transação: se algum item for inválido, nenhum é salvo.
  /// Cada linha guarda o snapshot dos valores por 100 g do alimento.
  Future<void> addItems(
    LocalDate date,
    MealType meal,
    List<FoodPortion> items,
  ) => _db.transaction(() async {
    var position = await _nextPosition(date, meal);
    for (final item in items) {
      if (!item.portion.isValid) {
        throw ArgumentError.value(item.portion.grams, 'grams', item.foodName);
      }
      await _db
          .into(_db.diaryItems)
          .insert(
            DiaryItemsCompanion.insert(
              id: newId(),
              date: date,
              meal: meal,
              position: position++,
              foodId: Value(item.foodId),
              foodName: item.foodName,
              measureLabel: item.portion.measureLabel,
              measureGrams: item.portion.measureGrams,
              quantity: item.portion.quantity,
              grams: item.portion.grams,
              kcal100: item.per100.kcal,
              protein100: item.per100.protein,
              carb100: item.per100.carb,
              fat100: item.per100.fat,
              fiber100: item.per100.fiber,
              sodium100: item.per100.sodium,
              createdAt: DateTime.now(),
            ),
          );
    }
  });

  /// Altera a porção de um item. O snapshot nutricional não muda.
  Future<void> updatePortion(String id, Portion portion) {
    if (!portion.isValid) throw ArgumentError.value(portion.grams, 'grams');
    return (_db.update(_db.diaryItems)..where((t) => t.id.equals(id))).write(
      DiaryItemsCompanion(
        measureLabel: Value(portion.measureLabel),
        measureGrams: Value(portion.measureGrams),
        quantity: Value(portion.quantity),
        grams: Value(portion.grams),
      ),
    );
  }

  Future<void> deleteItem(String id) =>
      (_db.delete(_db.diaryItems)..where((t) => t.id.equals(id))).go();

  /// Recoloca um item excluído, para a ação de desfazer.
  Future<void> restoreItem(DiaryItemRow item) =>
      _db.into(_db.diaryItems).insertOnConflictUpdate(item);

  /// O registro mais recente de um alimento, para abrir a escolha de porção
  /// na última porção usada.
  Future<DiaryItemRow?> lastForFood(String foodId) =>
      (_db.select(_db.diaryItems)
            ..where((t) => t.foodId.equals(foodId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  /// Copia uma refeição de um dia para outro e devolve quantos itens copiou.
  ///
  /// As linhas copiadas são registros novos, com snapshot tirado agora: se o
  /// alimento ainda existe, valem os valores atuais dele; se não, os do
  /// registro original.
  Future<int> copyMeal({
    required LocalDate fromDate,
    required MealType fromMeal,
    required LocalDate toDate,
    required MealType toMeal,
  }) => _db.transaction(() async {
    final source = await _mealItems(fromDate, fromMeal);
    final portions = <FoodPortion>[];
    for (final item in source) {
      final food = item.foodId == null
          ? null
          : await (_db.select(
              _db.foods,
            )..where((t) => t.id.equals(item.foodId!))).getSingleOrNull();
      portions.add(
        FoodPortion(
          foodId: item.foodId,
          foodName: food?.name ?? item.foodName,
          per100: food?.per100 ?? item.per100,
          portion: Portion(
            measureLabel: item.measureLabel,
            measureGrams: item.measureGrams,
            quantity: item.quantity,
          ),
        ),
      );
    }
    await addItems(toDate, toMeal, portions);
    return portions.length;
  });

  /// Dias anteriores a [before] que têm registros, do mais recente ao mais
  /// antigo, para escolher de onde copiar uma refeição.
  Future<List<LocalDate>> recentDaysWithItems({
    required LocalDate before,
    int limit = 14,
  }) async {
    final query = _db.selectOnly(_db.diaryItems, distinct: true)
      ..addColumns([_db.diaryItems.date])
      ..where(_db.diaryItems.date.isSmallerThanValue(before.toIso()))
      ..orderBy([OrderingTerm.desc(_db.diaryItems.date)])
      ..limit(limit);
    final rows = await query.get();
    return rows
        .map((row) => LocalDate.parse(row.read(_db.diaryItems.date)!))
        .toList();
  }

  Future<List<DiaryItemRow>> itemsOfDay(LocalDate date) =>
      (_db.select(_db.diaryItems)
            ..where((t) => t.date.equalsValue(date))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();
}
