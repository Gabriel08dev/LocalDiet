import 'package:drift/drift.dart';

import '../domain/local_date.dart';
import '../domain/profile_enums.dart';

/// Persiste [LocalDate] como texto `AAAA-MM-DD`, no banco e no backup.
class LocalDateConverter extends TypeConverter<LocalDate, String>
    with JsonTypeConverter<LocalDate, String> {
  const LocalDateConverter();

  @override
  LocalDate fromSql(String fromDb) => LocalDate.parse(fromDb);

  @override
  String toSql(LocalDate value) => value.toIso();
}

enum FoodSource { taco, user }

enum MeasureSource { system, user }

/// O que o usuário marcou para uma refeição do Plano Base em um dia.
enum PlanCheckStatus {
  /// Comeu o que estava planejado.
  followed,

  /// Comeu outra coisa no lugar.
  other,
}

/// Alimentos da TACO e alimentos criados pelo usuário.
///
/// O `id` é estável entre reimportações e backups: `taco:<número>` para a
/// TACO e `user:<aleatório>` para os do usuário. Alimentos nunca são
/// apagados, apenas desativados, para que Diário e Plano continuem resolvendo.
@DataClassName('FoodRow')
@TableIndex(name: 'foods_by_source', columns: {#source, #isActive})
class Foods extends Table {
  TextColumn get id => text()();
  TextColumn get source => textEnum<FoodSource>()();
  IntColumn get tacoNumber => integer().nullable()();
  TextColumn get name => text()();

  /// Nome normalizado, indexado pela busca.
  TextColumn get searchText => text()();
  TextColumn get category => text().nullable()();

  // Valores por 100 g usados em somas. Null quando a fonte não traz número.
  RealColumn get kcal => real().nullable()();
  RealColumn get protein => real().nullable()();
  RealColumn get carb => real().nullable()();
  RealColumn get fat => real().nullable()();
  RealColumn get fiber => real().nullable()();
  RealColumn get sodium => real().nullable()();

  /// Todos os nutrientes da fonte, com os símbolos originais (Tr, NA, *).
  TextColumn get nutrientsJson => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Medidas caseiras: as do sistema, com fonte documentada, e as do usuário.
@DataClassName('MeasureRow')
@TableIndex(name: 'measures_by_food', columns: {#foodId})
class Measures extends Table {
  TextColumn get id => text()();
  TextColumn get foodId => text().references(Foods, #id)();
  TextColumn get source => textEnum<MeasureSource>()();
  TextColumn get label => text()();

  /// Gramas de uma unidade da medida.
  RealColumn get grams => real()();

  /// Fonte e página da conversão, obrigatória para medidas do sistema.
  TextColumn get reference => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Versão importada de cada asset de dados.
@DataClassName('AssetVersionRow')
class AssetVersions extends Table {
  TextColumn get asset => text()();
  TextColumn get version => text()();
  IntColumn get itemCount => integer()();
  DateTimeColumn get importedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {asset};
}

/// Itens consumidos.
///
/// Cada linha guarda um snapshot do alimento no momento do registro (nome e
/// valores por 100 g), de modo que mudanças futuras na base não alterem o
/// histórico. `foodId` é só uma referência fraca, usada para atalhos.
@DataClassName('DiaryItemRow')
@TableIndex(name: 'diary_items_by_day', columns: {#date, #meal, #position})
@TableIndex(name: 'diary_items_by_food', columns: {#foodId})
class DiaryItems extends Table {
  TextColumn get id => text()();
  TextColumn get date => text().map(const LocalDateConverter())();
  TextColumn get meal => textEnum<MealType>()();
  IntColumn get position => integer()();
  TextColumn get foodId => text().nullable()();
  TextColumn get foodName => text()();
  TextColumn get measureLabel => text()();

  /// Gramas de uma unidade da medida usada (1 quando a medida é grama).
  RealColumn get measureGrams => real()();
  RealColumn get quantity => real()();
  RealColumn get grams => real()();
  RealColumn get kcal100 => real()();
  RealColumn get protein100 => real()();
  RealColumn get carb100 => real()();
  RealColumn get fat100 => real()();
  RealColumn get fiber100 => real()();
  RealColumn get sodium100 => real()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Itens do Plano Base. Os nutrientes são lidos do alimento ao exibir.
@DataClassName('PlanItemRow')
@TableIndex(name: 'plan_items_by_meal', columns: {#meal, #position})
class PlanItems extends Table {
  TextColumn get id => text()();
  TextColumn get meal => textEnum<MealType>()();
  IntColumn get position => integer()();
  TextColumn get foodId => text().references(Foods, #id)();
  TextColumn get measureLabel => text()();
  RealColumn get measureGrams => real()();
  RealColumn get quantity => real()();
  RealColumn get grams => real()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Marcação diária de cada refeição do Plano Base: seguida ou trocada.
///
/// Só existe linha para o que o usuário marcou. A marcação não guarda os
/// alimentos: o que foi comido está no Diário.
@DataClassName('PlanCheckRow')
class PlanChecks extends Table {
  TextColumn get date => text().map(const LocalDateConverter())();
  TextColumn get meal => textEnum<MealType>()();
  TextColumn get status => textEnum<PlanCheckStatus>()();
  DateTimeColumn get checkedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {date, meal};
}

@DataClassName('BodyMeasurementRow')
@TableIndex(name: 'body_measurements_by_date', columns: {#date})
class BodyMeasurements extends Table {
  TextColumn get id => text()();
  TextColumn get date => text().map(const LocalDateConverter())();
  RealColumn get weightKg => real().nullable()();
  RealColumn get waistCm => real().nullable()();
  RealColumn get neckCm => real().nullable()();
  RealColumn get hipCm => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Perfil do usuário. Há no máximo uma linha, com `id` 1.
@DataClassName('ProfileRow')
class Profiles extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get birthDate => text().map(const LocalDateConverter())();
  TextColumn get sex => textEnum<Sex>()();
  RealColumn get heightCm => real()();
  TextColumn get goal => textEnum<Goal>()();
  TextColumn get activity => textEnum<ActivityLevel>()();

  /// Meta calórica definida pelo usuário, que substitui a calculada.
  RealColumn get manualKcalTarget => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FavoriteRow')
class Favorites extends Table {
  TextColumn get foodId => text().references(Foods, #id)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {foodId};
}

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
