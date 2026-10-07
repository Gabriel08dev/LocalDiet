import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../../data/tables.dart';
import '../../domain/local_date.dart';
import '../../domain/nutrients.dart';
import '../../domain/portion.dart';
import '../../domain/profile_enums.dart';
import '../../providers.dart';
import '../format.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/portion_sheet.dart';
import 'home_screen.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final today = ref.read(todayProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: ref.read(selectedDateProvider).toLocalNoon(),
      firstDate: DateTime(2000),
      lastDate: today.addDays(365).toLocalNoon(),
    );
    if (picked != null) {
      ref
          .read(selectedDateProvider.notifier)
          .select(LocalDate.fromDateTime(picked));
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    DiaryItemRow item,
  ) async {
    final portion = await showPortionSheet(
      context,
      foodId: item.foodId,
      foodName: item.foodName,
      per100: item.per100,
      initial: Portion(
        measureLabel: item.measureLabel,
        measureGrams: item.measureGrams,
        quantity: item.quantity,
      ),
      actionLabel: S.save,
    );
    if (portion == null) return;
    await ref.read(diaryRepositoryProvider).updatePortion(item.id, portion);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    DiaryItemRow item,
  ) async {
    final diary = ref.read(diaryRepositoryProvider);
    await diary.deleteItem(item.id);
    if (!context.mounted) return;
    showUndo(
      context,
      S.itemRemoved(item.foodName),
      () => diary.restoreItem(item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final today = ref.watch(todayProvider);
    final items = ref.watch(diaryDayProvider(date));
    final comparison = ref.watch(dayComparisonProvider(date));
    final plan = ref.watch(planProvider).value ?? const [];
    final checks = ref.watch(planChecksProvider(date)).value ?? const {};
    final selection = ref.read(selectedDateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(formatRelativeDay(date, today)),
        actions: [
          IconButton(
            onPressed: () => selection.select(date.addDays(-1)),
            icon: const Icon(Icons.chevron_left),
            tooltip: S.previousDay,
          ),
          IconButton(
            onPressed: () => _pickDate(context, ref),
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: S.chooseDay,
          ),
          IconButton(
            onPressed: () => selection.select(date.addDays(1)),
            icon: const Icon(Icons.chevron_right),
            tooltip: S.nextDay,
          ),
        ],
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            const EmptyState(icon: Icons.error_outline, title: S.loadFailed),
        data: (list) => ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Gap.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: Gap.md,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Text(
                          formatKcal(comparison.kcal.consumed),
                          style: context.text.headlineSmall,
                        ),
                        KcalStatusText(
                          comparison.kcal,
                          style: context.text.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: Gap.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: comparison.kcal.progress ?? 0,
                        minHeight: 8,
                        color: comparison.kcal.isOver
                            ? context.appColors.over
                            : context.colors.primary,
                        backgroundColor: context.colors.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: Gap.lg),
                    MacroBars(comparison),
                  ],
                ),
              ),
            ),
            for (final meal in MealType.values)
              MealBlock(
                title: mealLabel(meal),
                status: switch (checks[meal]) {
                  PlanCheckStatus.followed => S.planFollowed,
                  PlanCheckStatus.other => S.otherMeal,
                  null => null,
                },
                onAdd: () => context.push(
                  addFoodLocation(target: 'diary', meal: meal, date: date),
                ),
                menu: PopupMenuButton<void>(
                  tooltip: S.moreOptions,
                  itemBuilder: (context) => [
                    if (checks[meal] != PlanCheckStatus.followed &&
                        plan.any((entry) => entry.item.meal == meal))
                      PopupMenuItem(
                        onTap: () =>
                            followPlannedMeal(context, ref, date, meal),
                        child: const Text(S.followPlan),
                      ),
                    if (checks[meal] != null)
                      PopupMenuItem(
                        onTap: () => ref
                            .read(planRepositoryProvider)
                            .clearCheck(date, meal),
                        child: const Text(S.clearPlanCheck),
                      ),
                    PopupMenuItem(
                      onTap: () =>
                          _copyFromAnotherDay(context, ref, date, meal),
                      child: const Text(S.copyFromAnotherDay),
                    ),
                  ],
                ),
                lines: [
                  for (final item in list.where((item) => item.meal == meal))
                    MealLine(
                      id: item.id,
                      title: item.foodName,
                      subtitle: S.portionText(
                        Portion(
                          measureLabel: item.measureLabel,
                          measureGrams: item.measureGrams,
                          quantity: item.quantity,
                        ),
                      ),
                      kcal: item.nutrients.kcal,
                      onTap: () => _edit(context, ref, item),
                      onDelete: () => _delete(context, ref, item),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Uma refeição de um dia anterior que pode ser copiada.
class _PastMeal {
  const _PastMeal(this.date, this.meal, this.items);

  final LocalDate date;
  final MealType meal;
  final List<DiaryItemRow> items;

  double get kcal => Nutrients.sum(items.map((item) => item.nutrients)).kcal;
}

Future<void> _copyFromAnotherDay(
  BuildContext context,
  WidgetRef ref,
  LocalDate date,
  MealType meal,
) async {
  final diary = ref.read(diaryRepositoryProvider);
  final today = ref.read(todayProvider);
  final days = await diary.recentDaysWithItems(before: date);
  final meals = <_PastMeal>[];
  for (final day in days) {
    final items = await diary.itemsOfDay(day);
    for (final type in MealType.values) {
      final ofMeal = items.where((item) => item.meal == type).toList();
      if (ofMeal.isNotEmpty) meals.add(_PastMeal(day, type, ofMeal));
    }
  }
  if (!context.mounted) return;

  final chosen = await showModalBottomSheet<_PastMeal>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, controller) => ListView(
        controller: controller,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.sm),
            child: Text(
              S.copyTo(mealLabel(meal)),
              style: context.text.titleLarge,
            ),
          ),
          if (meals.isEmpty)
            const EmptyState(
              icon: Icons.history,
              title: S.nothingToCopy,
              message: S.nothingToCopyHelp,
            ),
          for (final past in meals)
            ListTile(
              title: Text(
                '${formatRelativeDay(past.date, today)} · '
                '${mealLabel(past.meal)}',
              ),
              subtitle: Text(
                past.items.map((item) => item.foodName).join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(formatKcal(past.kcal)),
              onTap: () => Navigator.of(context).pop(past),
            ),
        ],
      ),
    ),
  );
  if (chosen == null) return;

  final copied = await diary.copyMeal(
    fromDate: chosen.date,
    fromMeal: chosen.meal,
    toDate: date,
    toMeal: meal,
  );
  if (context.mounted) showMessage(context, S.itemsCopied(copied));
}
