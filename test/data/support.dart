import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:localdiet/data/app_database.dart';
import 'package:localdiet/data/asset_importer.dart';
import 'package:localdiet/domain/nutrients.dart';
import 'package:localdiet/domain/portion.dart';

/// Banco em memória, vazio.
AppDatabase memoryDatabase() {
  // Alguns testes abrem dois bancos independentes de proposito.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// Conteúdo real do asset da TACO.
String tacoAsset() => File(tacoAssetPath).readAsStringSync();

/// Conteúdo real do asset de medidas caseiras.
String measuresAsset() => File(measuresAssetPath).readAsStringSync();

/// Banco em memória com a TACO e as medidas caseiras do app.
Future<AppDatabase> databaseWithAssets() async {
  final db = await databaseWithTaco();
  await AssetImporter(db).syncMeasures(measuresAsset());
  return db;
}

/// Banco em memória já com a TACO importada.
Future<AppDatabase> databaseWithTaco() async {
  final db = memoryDatabase();
  await AssetImporter(db).syncTaco(tacoAsset());
  return db;
}

/// Uma linha de asset da TACO com os campos que o importador lê.
String tacoLine(
  int number,
  String name, {
  Object? kcal = 100,
  Object? protein = 1.0,
  Object? carb = 20.0,
  Object? fat = 0.5,
  Object? fiber = 1.0,
  Object? sodium = 5,
}) {
  String raw(Object? value) => value is String ? '"$value"' : '$value';
  return '{"n":$number,"name":"$name","category":"Teste",'
      '"energy_kcal":${raw(kcal)},"protein_g":${raw(protein)},'
      '"carb_g":${raw(carb)},"lipid_g":${raw(fat)},'
      '"fiber_g":${raw(fiber)},"sodium_mg":${raw(sodium)}}';
}

FoodPortion portionOf(FoodRow food, double grams) => FoodPortion(
  foodId: food.id,
  foodName: food.name,
  per100: food.per100,
  portion: Portion.grams(grams),
);

const riceId = 'taco:1';

const sampleNutrients = Nutrients(
  kcal: 380,
  protein: 80,
  carb: 6,
  fat: 4,
  fiber: 0,
  sodium: 200,
);
