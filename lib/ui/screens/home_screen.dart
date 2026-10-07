import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../../domain/local_date.dart';
import '../../domain/profile_enums.dart';
import '../../providers.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Caminho da tela de adicionar alimentos a uma refeição.
String addFoodLocation({
  required String target,
  required MealType meal,
  LocalDate? date,
}) => Uri(
  path: '/add',
  queryParameters: {
    'target': target,
    'meal': meal.name,
    'date': ?date?.toIso(),
  },
).toString();

/// A refeição mais provável para o horário, usada como sugestão inicial.
MealType mealForHour(int hour) {
  if (hour < 10) return MealType.breakfast;
  if (hour < 15) return MealType.lunch;
  if (hour < 18) return MealType.snack;
  return MealType.dinner;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final profile = ref.watch(profileProvider).value;
    final items = ref.watch(diaryDayProvider(today)).value ?? const [];
    final comparison = ref.watch(dayComparisonProvider(today));
    final target = ref.watch(calorieTargetProvider);
    final hasPlan = ref.watch(planTotalProvider) != null;

    void add(MealType meal) =>
        context.push(addFoodLocation(target: 'diary', meal: meal, date: today));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.xxl),
          children: [
            Text(
              profile == null ? S.appName : S.hello(profile.name),
              style: context.text.headlineMedium,
            ),
            Text(
              S.todayLong(today),
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Gap.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Gap.lg),
                child: Column(
                  children: [
                    Wrap(
                      spacing: Gap.xl,
                      runSpacing: Gap.md,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        KcalRing(comparison.kcal),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KcalStatusText(
                              comparison.kcal,
                              style: context.text.titleMedium,
                            ),
                            if (target != null) ...[
                              const SizedBox(height: Gap.xs),
                              Text(
                                S.kcalTargetLine(target.value),
                                style: context.text.bodyMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: Gap.lg),
                    MacroBars(comparison),
                    if (!hasPlan) ...[
                      const SizedBox(height: Gap.md),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          S.macrosNeedPlan,
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: Gap.md),
            FilledButton.icon(
              onPressed: () => add(mealForHour(DateTime.now().hour)),
              icon: const Icon(Icons.add),
              label: const Text(S.logFood),
            ),
            if (target != null && target.isBelowBmr) ...[
              const SizedBox(height: Gap.md),
              const InfoBanner(S.belowBmrNotice, icon: Icons.warning_amber),
            ],
            const SectionHeader(S.todayMeals),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final meal in MealType.values)
                    _MealRow(
                      meal: meal,
                      items: items.where((item) => item.meal == meal).toList(),
                      onAdd: () => add(meal),
                      onOpen: () {
                        ref.read(selectedDateProvider.notifier).select(today);
                        context.go('/diary');
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({
    required this.meal,
    required this.items,
    required this.onAdd,
    required this.onOpen,
  });

  final MealType meal;
  final List<DiaryItemRow> items;
  final VoidCallback onAdd;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final kcal = items.fold<double>(
      0,
      (sum, item) => sum + item.nutrients.kcal,
    );
    return ListTile(
      title: Text(mealLabel(meal)),
      subtitle: Text(
        items.isEmpty ? S.nothingLogged : S.itemsAndKcal(items.length, kcal),
      ),
      trailing: IconButton(
        onPressed: onAdd,
        icon: const Icon(Icons.add_circle_outline),
        tooltip: S.addToMeal(mealLabel(meal)),
      ),
      onTap: items.isEmpty ? onAdd : onOpen,
    );
  }
}
