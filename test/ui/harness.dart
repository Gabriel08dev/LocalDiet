import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/data/app_database.dart';
import 'package:localdiet/data/asset_importer.dart';
import 'package:localdiet/data/repositories/food_repository.dart';
import 'package:localdiet/data/repositories/profile_repository.dart';
import 'package:localdiet/domain/local_date.dart';
import 'package:localdiet/domain/portion.dart';
import 'package:localdiet/domain/profile_enums.dart';
import 'package:localdiet/providers.dart';
import 'package:localdiet/ui/app.dart';

const testToday = LocalDate(2026, 10, 7);

final _taco = File(tacoAssetPath).readAsStringSync();
final _measures = File(measuresAssetPath).readAsStringSync();

/// Abre o app inteiro sobre um banco em memória com a TACO real.
///
/// Com [onboarded], o perfil e a primeira medição já existem. [seed] permite
/// gravar mais dados antes de a interface subir.
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  bool onboarded = true,
  Size size = const Size(390, 844),
  double textScale = 1,
  double pixelRatio = 1,
  ThemeMode? themeMode,
  Future<void> Function(AppDatabase db)? seed,
}) async {
  tester.view.devicePixelRatio = pixelRatio;
  tester.view.physicalSize = size * pixelRatio;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  // Ao gerar capturas, as sombras aparecem como no aparelho, em vez do
  // contorno que os testes desenham no lugar. closeApp restaura o padrão.
  debugDisableShadows = !autoUpdateGoldenFiles;

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase(NativeDatabase.memory());
  await tester.runAsync(() async {
    await AssetImporter(db).syncTaco(_taco);
    await AssetImporter(db).syncMeasures(_measures);
    if (onboarded) {
      await ProfileRepository(db).completeOnboarding(
        name: 'Gabriel',
        birthDate: const LocalDate(1996, 5, 15),
        sex: Sex.male,
        heightCm: 178,
        goal: Goal.maintain,
        activity: ActivityLevel.moderate,
        today: testToday.addDays(-30),
        weightKg: 82.5,
        waistCm: 90,
        neckCm: 39,
      );
    }
    if (themeMode != null) {
      await SettingsRepository(db).setValue('theme', themeMode.name);
    }
    await seed?.call(db);
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        assetLoaderProvider.overrideWithValue(
          (path) async => path == tacoAssetPath ? _taco : _measures,
        ),
        todayProvider.overrideWithValue(testToday),
      ],
      child: const LocalDietApp(),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

/// Desmonta o app e fecha o banco, sem deixar temporizadores pendentes.
Future<void> closeApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(db.close);
  debugDisableShadows = true;
}

/// Vai para uma aba da navegação inferior pelo rótulo.
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

/// Digita na busca de alimentos e espera o resultado.
Future<void> searchFood(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField).first, query);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}

/// Uma porção em gramas de um alimento da base.
Future<FoodPortion> portionOfFood(
  AppDatabase db,
  String id,
  double grams,
) async {
  final food = (await FoodRepository(db).byId(id))!;
  return FoodPortion(
    foodId: food.id,
    foodName: food.name,
    per100: food.per100,
    portion: Portion.grams(grams),
  );
}
