import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../../data/repositories/plan_repository.dart';
import '../../data/tables.dart';
import '../../domain/calorie_target.dart';
import '../../domain/intake_comparison.dart';
import '../../domain/local_date.dart';
import '../../domain/nutrients.dart';
import '../../domain/profile_enums.dart';
import '../../providers.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/motion.dart';

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
  // Lista vazia: a refeição já estava marcada e nada novo foi registrado.
  if (ids.isEmpty || !context.mounted) return;
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.todayLong(today),
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    profile == null ? S.appName : S.hello(profile.name),
                    style: context.text.headlineMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.lg),
            Reveal(
              child: _DayHero(
                status: comparison.kcal,
                target: target,
                onLog: () => add(mealForHour(DateTime.now().hour)),
              ),
            ),
            const SizedBox(height: Gap.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Gap.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MacroBars(comparison),
                    if (plan.isEmpty) ...[
                      const SizedBox(height: Gap.md),
                      Text(
                        S.macrosNeedPlan,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
                  for (final (index, meal) in MealType.values.indexed) ...[
                    if (index > 0)
                      const Divider(indent: Gap.lg, endIndent: Gap.lg),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// O cartão de destaque do Início: calorias do dia frente à meta e o atalho
/// para registrar uma refeição.
class _DayHero extends StatelessWidget {
  const _DayHero({
    required this.status,
    required this.target,
    required this.onLog,
  });

  final IntakeStatus status;
  final CalorieTarget? target;
  final VoidCallback onLog;

  /// O que o número em destaque representa: o que falta ou o que passou.
  String get _label {
    if (!status.hasTarget) return S.noKcalTarget;
    return status.isOver ? S.kcalOverLabel : S.kcalRemainingLabel;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.appColors;
    final soft = app.onHero.withValues(alpha: 0.72);
    // O botão inverte as cores do cartão: escuro sobre o pastel claro e
    // claro sobre o degradê escuro.
    final onButton =
        ThemeData.estimateBrightnessForColor(app.onHero) == Brightness.dark
        ? Colors.white
        : const Color(0xFF1B1740);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: app.hero,
        ),
        borderRadius: BorderRadius.circular(Corner.xl),
        boxShadow: [
          BoxShadow(
            color: app.glow,
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        children: [
          Row(
            children: [
              KcalRing(status, size: 108, onHero: true),
              const SizedBox(width: Gap.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label,
                      style: context.text.labelLarge?.copyWith(color: soft),
                    ),
                    if (status.hasTarget)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          S.kcalAmount(
                            status.isOver ? status.excess! : status.remaining!,
                          ),
                          style: context.text.headlineMedium?.copyWith(
                            color: status.isOver ? app.heroOver : app.onHero,
                          ),
                        ),
                      ),
                    if (target != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        S.kcalTargetLine(target!.value),
                        style: context.text.bodyMedium?.copyWith(color: soft),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: app.onHero,
                foregroundColor: onButton,
              ),
              onPressed: onLog,
              icon: const Icon(Icons.add),
              label: const Text(S.logFood),
            ),
          ),
        ],
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
    return AnimatedSize(
      duration: Motion.of(context, Motion.base),
      curve: Motion.curve,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: Motion.of(context, Motion.fast),
        child: KeyedSubtree(
          key: ValueKey(awaitsAnswer),
          child: awaitsAnswer ? _buildQuestion(context) : _buildRow(context),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context) {
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
      contentPadding: const EdgeInsets.only(left: Gap.lg, right: Gap.xs),
      leading: IconBadge(
        check == PlanCheckStatus.followed ? Icons.check : mealIcon(meal),
        tone: check == PlanCheckStatus.followed
            ? context.appColors.mint
            : mealTone(context, meal),
      ),
      title: Text(mealLabel(meal), style: context.text.titleMedium),
      subtitle: Text(subtitle),
      trailing: IconButton(
        onPressed: onAdd,
        icon: const Icon(Icons.add_circle),
        color: context.colors.primary,
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
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.lg, Gap.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(mealIcon(meal), tone: mealTone(context, meal)),
              const SizedBox(width: Gap.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mealLabel(meal), style: context.text.titleMedium),
                    Text(
                      S.plannedSummary(planned.length, plannedKcal),
                      style: context.text.bodyMedium?.copyWith(color: muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      planned.map((entry) => entry.food.name).join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.xs,
            children: [
              FilledButton.icon(
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
