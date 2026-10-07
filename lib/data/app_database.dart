import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/local_date.dart';
import '../domain/nutrients.dart';
import '../domain/profile_enums.dart';
import 'app_database.steps.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Nome do arquivo do banco. É diferente do usado pela primeira versão do
/// app para que uma instalação por cima não tente abrir o banco antigo.
const databaseName = 'localdiet2';

@DriftDatabase(
  tables: [
    Foods,
    Measures,
    AssetVersions,
    DiaryItems,
    PlanItems,
    PlanChecks,
    BodyMeasurements,
    Profiles,
    Favorites,
    Settings,
  ],
  include: {'search.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: databaseName));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      // v2: marcação diária das refeições do Plano Base.
      from1To2: (m, schema) async {
        await m.createTable(schema.planChecks);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

extension FoodRowNutrients on FoodRow {
  /// Valores por 100 g. Nutriente sem número na fonte conta como zero.
  Nutrients get per100 => Nutrients(
    kcal: kcal ?? 0,
    protein: protein ?? 0,
    carb: carb ?? 0,
    fat: fat ?? 0,
    fiber: fiber ?? 0,
    sodium: sodium ?? 0,
  );
}

extension FoodRowEnergy on FoodRow {
  /// A fonte não traz a energia deste alimento: na TACO, análise em
  /// reavaliação (`*`) ou não realizada.
  ///
  /// "Não aplicável" (`NA`, como no sal) não entra aqui: é zero de fato.
  /// Quem mostra calorias usa isto para não exibir "0 kcal" no lugar de um
  /// valor que a fonte não informa.
  bool get isEnergyUnknown {
    if (kcal != null || source != FoodSource.taco) return false;
    final json = nutrientsJson;
    if (json == null) return true;
    return (jsonDecode(json) as Map<String, dynamic>)['energy_kcal'] != 'NA';
  }
}

extension DiaryItemRowNutrients on DiaryItemRow {
  /// Valores por 100 g gravados no momento do registro.
  Nutrients get per100 => Nutrients(
    kcal: kcal100,
    protein: protein100,
    carb: carb100,
    fat: fat100,
    fiber: fiber100,
    sodium: sodium100,
  );

  /// Valores da porção registrada.
  Nutrients get nutrients => per100.forGrams(grams);
}
