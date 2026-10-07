import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../../data/repositories/plan_repository.dart';
import '../../data/tables.dart';
import '../../domain/local_date.dart';
import '../../domain/nutrients.dart';
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

/// Marca a refeição como seguida e registra no Diário o que estava no plano.
Future<void> followPlannedMeal(
  BuildContext context,
  WidgetRef ref,
  LocalDate date,
  MealType meal,
) async {
  final plan = ref.read(planRepositoryProvider);
  final ids = await plan.followMeal(date, meal);
  if (!context.mounted) return;
  showUndo(
    context,
    S.planFollowedMessage(mealLabel(meal)),
    () => plan.undoFollow(date, meal, ids),
  );
}

/// Marca que a refeição foi trocada e abre o registro do que foi comido.
Future<void> logOtherMeal(
  BuildContext context,
  WidgetRef ref,
  LocalDate date,
  MealType meal,
) async {
  await ref.read(planRepositoryProvider).markOther(date, meal);
  if (!context.mounted) return;
  context.push(addFoodLocation(target: 'diary', meal: meal, date: date));
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final profile = ref.watch(profileProvider).value;
    final items = ref.watch(diaryDayProvider(today)).value ?? const [];
    final plan = ref.watch(planProvider).value ?? const [];
    final checks = ref.watch(planChecksProvider(today)).value ?? const {};
    final comparison = ref.watch(dayComparisonProvider(today));
    final target = ref.watch(calorieTargetProvider);

    void add(MealType meal) =>
        context.push(addFoodLocation(target: 'diary', meal: meal, date: today));

    void openDiary() {
      ref.read(selectedDateProvider.notifier).select(today);
      context.go('/diary');
    }

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
                    if (plan.isEmpty) ...[
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final meal in MealType.values)
                    _MealRow(
                      meal: meal,
                      items: items.where((item) => item.meal == meal).toList(),
                      planned: plan
                          .where((entry) => entry.item.meal == meal)
                          .toList(),
                      check: checks[meal],
                      onAdd: () => add(meal),
                      onOpen: openDiary,
                      onFollow: () =>
                          followPlannedMeal(context, ref, today, meal),
                      onOther: () => logOtherMeal(context, ref, today, meal),
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

/// Uma refeição do dia no Início.
///
/// Quando o Plano Base tem itens para a refeição e nada foi registrado nem
/// marcado, a linha mostra o que estava planejado e pergunta se o plano foi
/// seguido. Nos demais casos, mostra o que já foi registrado.
class _MealRow extends StatelessWidget {
  const _MealRow({
    required this.meal,
    required this.items,
    required this.planned,
    required this.check,
    required this.onAdd,
    required this.onOpen,
    required this.onFollow,
    required this.onOther,
  });

  final MealType meal;
  final List<DiaryItemRow> items;
  final List<PlanEntry> planned;
  final PlanCheckStatus? check;
  final VoidCallback onAdd;
  final VoidCallback onOpen;
  final VoidCallback onFollow;
  final VoidCallback onOther;

  @override
  Widget build(BuildContext context) {
    final awaitsAnswer = planned.isNotEmpty && check == null && items.isEmpty;
    if (awaitsAnswer) return _buildQuestion(context);

    final kcal = Nutrients.sum(items.map((item) => item.nutrients)).kcal;
    final logged = items.isEmpty
        ? S.nothingLogged
        : S.itemsAndKcal(items.length, kcal);
    final subtitle = switch (check) {
      PlanCheckStatus.followed => '${S.planFollowed} · $logged',
      PlanCheckStatus.other => '${S.otherMeal} · $logged',
      null => logged,
    };
    return ListTile(
      title: Text(mealLabel(meal)),
      subtitle: Row(
        children: [
          if (check == PlanCheckStatus.followed) ...[
            Icon(Icons.check_circle, size: 16, color: context.colors.primary),
            const SizedBox(width: Gap.xs),
          ],
          Expanded(child: Text(subtitle)),
        ],
      ),
      trailing: IconButton(
        onPressed: onAdd,
        icon: const Icon(Icons.add_circle_outline),
        tooltip: S.addToMeal(mealLabel(meal)),
      ),
      onTap: items.isEmpty ? onAdd : onOpen,
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final plannedKcal = Nutrients.sum(planned.map((entry) => entry.nutrients))
        .kcal;
    final muted = context.colors.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.lg, Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mealLabel(meal), style: context.text.bodyLarge),
          const SizedBox(height: 2),
          Text(
            S.plannedSummary(planned.length, plannedKcal),
            style: context.text.bodyMedium?.copyWith(color: muted),
          ),
          Text(
            planned.map((entry) => entry.food.name).join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: Gap.sm),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.xs,
            children: [
              FilledButton.tonalIcon(
                style: compactButton,
                onPressed: onFollow,
                icon: const Icon(Icons.check, size: 18),
                label: Text(
                  S.followPlan,
                  semanticsLabel: S.followPlanFor(mealLabel(meal)),
                ),
              ),
              OutlinedButton(
                style: compactButton,
                onPressed: onOther,
                child: Text(
                  S.ateSomethingElse,
                  semanticsLabel: S.ateSomethingElseFor(mealLabel(meal)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
