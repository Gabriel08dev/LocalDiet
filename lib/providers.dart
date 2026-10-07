import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_database.dart';
import 'data/asset_importer.dart';
import 'data/repositories/backup_repository.dart';
import 'data/repositories/diary_repository.dart';
import 'data/repositories/food_repository.dart';
import 'data/repositories/measure_repository.dart';
import 'data/repositories/plan_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/tables.dart';
import 'domain/calorie_target.dart';
import 'domain/intake_comparison.dart';
import 'domain/local_date.dart';
import 'domain/nutrients.dart';
import 'domain/profile_enums.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Leitura de assets de texto, substituível em testes.
final assetLoaderProvider = Provider<Future<String> Function(String path)>(
  (ref) => rootBundle.loadString,
);

/// Sincroniza a TACO e as medidas com o banco na abertura do app.
final bootstrapProvider = FutureProvider<void>((ref) async {
  final importer = AssetImporter(ref.watch(databaseProvider));
  await importer.syncAll(ref.watch(assetLoaderProvider));
});

final foodRepositoryProvider = Provider(
  (ref) => FoodRepository(ref.watch(databaseProvider)),
);
final measureRepositoryProvider = Provider(
  (ref) => MeasureRepository(ref.watch(databaseProvider)),
);
final diaryRepositoryProvider = Provider(
  (ref) => DiaryRepository(ref.watch(databaseProvider)),
);
final planRepositoryProvider = Provider(
  (ref) => PlanRepository(ref.watch(databaseProvider)),
);
final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(ref.watch(databaseProvider)),
);
final bodyRepositoryProvider = Provider(
  (ref) => BodyRepository(ref.watch(databaseProvider)),
);
final settingsRepositoryProvider = Provider(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);
final backupRepositoryProvider = Provider(
  (ref) => BackupRepository(ref.watch(databaseProvider)),
);

/// O dia de hoje no relógio do aparelho, substituível em testes.
final todayProvider = Provider<LocalDate>((ref) => LocalDate.today());

/// O dia exibido no Diário.
class SelectedDate extends Notifier<LocalDate> {
  @override
  LocalDate build() => ref.watch(todayProvider);

  void select(LocalDate date) => state = date;
}

final selectedDateProvider = NotifierProvider<SelectedDate, LocalDate>(
  SelectedDate.new,
);

final profileProvider = StreamProvider<ProfileRow?>(
  (ref) => ref.watch(profileRepositoryProvider).watch(),
);

final measurementsProvider = StreamProvider<List<BodyMeasurementRow>>(
  (ref) => ref.watch(bodyRepositoryProvider).watchAll(),
);

final diaryDayProvider = StreamProvider.family<List<DiaryItemRow>, LocalDate>(
  (ref, date) => ref.watch(diaryRepositoryProvider).watchDay(date),
);

final planProvider = StreamProvider<List<PlanEntry>>(
  (ref) => ref.watch(planRepositoryProvider).watchAll(),
);

/// O que foi marcado em cada refeição do plano em um dia.
final planChecksProvider =
    StreamProvider.family<Map<MealType, PlanCheckStatus>, LocalDate>(
      (ref, date) => ref.watch(planRepositoryProvider).watchChecks(date),
    );

/// Adesão ao plano nos últimos sete dias, contando hoje.
final planAdherenceProvider = StreamProvider<PlanAdherence>((ref) {
  final today = ref.watch(todayProvider);
  return ref
      .watch(planRepositoryProvider)
      .watchAdherence(from: today.addDays(-6), to: today);
});

final userFoodsProvider = StreamProvider<List<FoodRow>>(
  (ref) => ref.watch(foodRepositoryProvider).watchUserFoods(),
);
final recentFoodsProvider = StreamProvider<List<FoodRow>>(
  (ref) => ref.watch(foodRepositoryProvider).watchRecents(),
);
final frequentFoodsProvider = StreamProvider<List<FoodRow>>(
  (ref) => ref.watch(foodRepositoryProvider).watchFrequents(),
);
final favoriteFoodsProvider = StreamProvider<List<FoodRow>>(
  (ref) => ref.watch(foodRepositoryProvider).watchFavorites(),
);

/// O peso mais recente registrado, em kg.
final latestWeightProvider = Provider<double?>((ref) {
  final measurements = ref.watch(measurementsProvider).value ?? const [];
  for (final measurement in measurements.reversed) {
    if (measurement.weightKg != null) return measurement.weightKg;
  }
  return null;
});

/// A meta calórica do perfil, ou null enquanto faltar perfil ou peso.
final calorieTargetProvider = Provider<CalorieTarget?>((ref) {
  final profile = ref.watch(profileProvider).value;
  final weight = ref.watch(latestWeightProvider);
  if (profile == null || weight == null) return null;
  return calorieTarget(
    sex: profile.sex,
    weightKg: weight,
    heightCm: profile.heightCm,
    ageYears: profile.birthDate.ageOn(ref.watch(todayProvider)),
    activity: profile.activity,
    goal: profile.goal,
    manualTarget: profile.manualKcalTarget,
  );
});

/// Total do Plano Base, ou null quando o plano está vazio.
final planTotalProvider = Provider<Nutrients?>((ref) {
  final entries = ref.watch(planProvider).value ?? const [];
  if (entries.isEmpty) return null;
  return Nutrients.sum(entries.map((entry) => entry.nutrients));
});

/// Total consumido em um dia.
final dayTotalProvider = Provider.family<Nutrients, LocalDate>((ref, date) {
  final items = ref.watch(diaryDayProvider(date)).value ?? const [];
  return Nutrients.sum(items.map((item) => item.nutrients));
});

/// Real × Meta de um dia.
final dayComparisonProvider = Provider.family<DayComparison, LocalDate>(
  (ref, date) => DayComparison.from(
    consumed: ref.watch(dayTotalProvider(date)),
    kcalTarget: ref.watch(calorieTargetProvider)?.value,
    plan: ref.watch(planTotalProvider),
  ),
);

const _themeKey = 'theme';

final themeModeProvider = StreamProvider<ThemeMode>(
  (ref) => ref
      .watch(settingsRepositoryProvider)
      .watchValue(_themeKey)
      .map(
        (value) => ThemeMode.values.firstWhere(
          (mode) => mode.name == value,
          orElse: () => ThemeMode.system,
        ),
      ),
);

Future<void> setThemeMode(WidgetRef ref, ThemeMode mode) =>
    ref.read(settingsRepositoryProvider).setValue(_themeKey, mode.name);
