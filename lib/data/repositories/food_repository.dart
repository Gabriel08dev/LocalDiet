import 'package:drift/drift.dart';

import '../../domain/nutrients.dart';
import '../../domain/profile_enums.dart';
import '../../domain/search_text.dart';
import '../app_database.dart';
import '../ids.dart';
import '../tables.dart';

/// Verdadeiro para um alimento cujo nome termina em "cru" ou "crua" e que tem
/// outro alimento ativo com o mesmo nome terminando em cozido, grelhado ou
/// assado.
const _rawWithReadyVersion =
    "(CASE WHEN f.search_text LIKE '% cru' THEN EXISTS ("
    'SELECT 1 FROM foods r WHERE r.is_active = 1 AND r.search_text IN ('
    "substr(f.search_text, 1, length(f.search_text) - 3) || 'cozido', "
    "substr(f.search_text, 1, length(f.search_text) - 3) || 'grelhado', "
    "substr(f.search_text, 1, length(f.search_text) - 3) || 'assado')) "
    "WHEN f.search_text LIKE '% crua' THEN EXISTS ("
    'SELECT 1 FROM foods r WHERE r.is_active = 1 AND r.search_text IN ('
    "substr(f.search_text, 1, length(f.search_text) - 4) || 'cozida', "
    "substr(f.search_text, 1, length(f.search_text) - 4) || 'grelhada', "
    "substr(f.search_text, 1, length(f.search_text) - 4) || 'assada')) "
    'ELSE 0 END)';

/// Prefixo do id dos alimentos criados pelo usuário.
const userFoodPrefix = 'user:';

class FoodRepository {
  FoodRepository(this._db);

  final AppDatabase _db;

  /// Busca alimentos ativos pelo texto digitado.
  ///
  /// Vêm primeiro os nomes que começam pelo primeiro termo, depois os
  /// alimentos do usuário, depois a relevância do FTS5 e os nomes mais curtos.
  ///
  /// Um alimento cru fica depois da sua versão pronta (cozida, grelhada ou
  /// assada) quando ela existe, porque é a pronta que costuma ser registrada.
  /// Quem digita "cru" na busca recebe o cru primeiro.
  Future<List<FoodRow>> search(String input, {int limit = 40}) async {
    final query = buildFtsQuery(input);
    if (query == null) return const [];
    final firstTerm = leadingSearchPrefix(input)!;
    final wantsRaw = searchTokens(input).any((term) => term.startsWith('cru'));
    final rows = await _db
        .customSelect(
          'SELECT f.* FROM food_search '
          'INNER JOIN foods f ON f.id = food_search.food_id '
          'WHERE food_search MATCH ?1 AND f.is_active = 1 '
          'ORDER BY (f.search_text LIKE ?2) DESC, '
          "(f.source = 'user') DESC, "
          '(?4 AND $_rawWithReadyVersion) ASC, '
          'bm25(food_search), length(f.name), f.name '
          'LIMIT ?3',
          variables: [
            Variable.withString(query),
            Variable.withString('$firstTerm%'),
            Variable.withInt(limit),
            Variable.withBool(!wantsRaw),
          ],
          readsFrom: {_db.foods},
        )
        .get();
    return rows.map((row) => _db.foods.map(row.data)).toList();
  }

  Future<FoodRow?> byId(String id) =>
      (_db.select(_db.foods)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// O alimento, acompanhando mudanças nele.
  Stream<FoodRow?> watchById(String id) => (_db.select(
    _db.foods,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<FoodRow?> byTacoNumber(int number) => (_db.select(
    _db.foods,
  )..where((t) => t.tacoNumber.equals(number))).getSingleOrNull();

  /// Os alimentos já registrados em [meal], cada um com o último uso e o
  /// número de usos naquela refeição.
  Stream<List<FoodRow>> _watchFromDiary(
    MealType meal,
    String orderBy,
    int limit,
  ) {
    final query = _db.customSelect(
      'SELECT f.*, MAX(d.created_at) AS last_used, COUNT(*) AS uses '
      'FROM diary_items d INNER JOIN foods f ON f.id = d.food_id '
      'WHERE f.is_active = 1 AND d.meal = ?1 '
      'GROUP BY f.id ORDER BY $orderBy LIMIT ?2',
      variables: [Variable.withString(meal.name), Variable.withInt(limit)],
      readsFrom: {_db.diaryItems, _db.foods},
    );
    return query.watch().map(
      (rows) => rows.map((row) => _db.foods.map(row.data)).toList(),
    );
  }

  /// Alimentos registrados mais recentemente em [meal] no Diário.
  ///
  /// Cada refeição tem o próprio histórico: o que foi registrado no almoço
  /// não aparece entre os recentes do café da manhã.
  Stream<List<FoodRow>> watchRecents(MealType meal, {int limit = 12}) =>
      _watchFromDiary(meal, 'last_used DESC', limit);

  /// Alimentos registrados mais vezes em [meal] no Diário.
  Stream<List<FoodRow>> watchFrequents(MealType meal, {int limit = 12}) =>
      _watchFromDiary(meal, 'uses DESC, last_used DESC', limit);

  Stream<List<FoodRow>> watchFavorites() {
    final query =
        _db.select(_db.favorites).join([
            innerJoin(_db.foods, _db.foods.id.equalsExp(_db.favorites.foodId)),
          ])
          ..where(_db.foods.isActive.equals(true))
          ..orderBy([OrderingTerm.asc(_db.foods.name)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(_db.foods)).toList(),
    );
  }

  Stream<bool> watchIsFavorite(String foodId) =>
      (_db.select(_db.favorites)..where((t) => t.foodId.equals(foodId)))
          .watchSingleOrNull()
          .map((row) => row != null);

  Future<void> setFavorite(String foodId, {required bool favorite}) async {
    if (favorite) {
      await _db
          .into(_db.favorites)
          .insertOnConflictUpdate(
            FavoritesCompanion.insert(
              foodId: foodId,
              createdAt: DateTime.now(),
            ),
          );
    } else {
      await (_db.delete(
        _db.favorites,
      )..where((t) => t.foodId.equals(foodId))).go();
    }
  }

  Stream<List<FoodRow>> watchUserFoods() =>
      (_db.select(_db.foods)
            ..where(
              (t) =>
                  t.source.equalsValue(FoodSource.user) &
                  t.isActive.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  /// Cria ou atualiza um alimento do usuário e devolve o id.
  ///
  /// Editar um alimento não altera itens já registrados no Diário, que
  /// guardam o snapshot do momento do registro.
  Future<String> saveUserFood({
    String? id,
    required String name,
    required Nutrients per100,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(name, 'name');
    // Só alimentos do usuário são editáveis; os da TACO vêm do asset.
    if (id != null && !id.startsWith(userFoodPrefix)) {
      throw ArgumentError.value(id, 'id', 'Não é um alimento do usuário');
    }
    final foodId = id ?? '$userFoodPrefix${newId()}';
    await _db
        .into(_db.foods)
        .insertOnConflictUpdate(
          FoodsCompanion.insert(
            id: foodId,
            source: FoodSource.user,
            name: trimmed,
            searchText: normalizeSearchText(trimmed),
            kcal: Value(per100.kcal),
            protein: Value(per100.protein),
            carb: Value(per100.carb),
            fat: Value(per100.fat),
            fiber: Value(per100.fiber),
            sodium: Value(per100.sodium),
            isActive: const Value(true),
          ),
        );
    return foodId;
  }

  /// Desativa um alimento do usuário. Ele some da busca, mas o histórico e o
  /// Plano continuam a resolvê-lo.
  Future<void> deactivateUserFood(String id) =>
      (_db.update(_db.foods)..where(
            (t) => t.id.equals(id) & t.source.equalsValue(FoodSource.user),
          ))
          .write(const FoodsCompanion(isActive: Value(false)));
}
