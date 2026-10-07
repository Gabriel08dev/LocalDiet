import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../../data/repositories/plan_repository.dart';
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

/// O Plano Base: a dieta planejada, refeição por refeição.
///
/// O total do plano é só a soma do que foi planejado. Ele não muda a meta
/// calórica do perfil, e o app não ajusta porções para aproximar os dois.
class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    PlanEntry entry,
  ) async {
    final item = entry.item;
    final portion = await showPortionSheet(
      context,
      foodId: entry.food.id,
      foodName: entry.food.name,
      per100: entry.food.per100,
      initial: Portion(
        measureLabel: item.measureLabel,
        measureGrams: item.measureGrams,
        quantity: item.quantity,
      ),
      actionLabel: S.save,
    );
    if (portion == null) return;
    await ref.read(planRepositoryProvider).updatePortion(item.id, portion);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    PlanEntry entry,
  ) async {
    final plan = ref.read(planRepositoryProvider);
    await plan.deleteItem(entry.item.id);
    if (!context.mounted) return;
    showUndo(
      context,
      S.itemRemoved(entry.food.name),
      () => plan.restoreItem(entry.item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(planProvider);
    final target = ref.watch(calorieTargetProvider);
    final adherence = ref.watch(planAdherenceProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text(S.planTitle)),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            const EmptyState(icon: Icons.error_outline, title: S.loadFailed),
        data: (list) {
          final total = Nutrients.sum(list.map((entry) => entry.nutrients));
          return ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Gap.lg),
                  child: list.isEmpty
                      ? Text(S.planEmpty, style: context.text.bodyMedium)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.planTotal, style: context.text.labelLarge),
                            const SizedBox(height: Gap.xs),
                            Text(
                              formatKcal(total.kcal),
                              style: context.text.headlineSmall,
                            ),
                            const SizedBox(height: Gap.xs),
                            MacroLine(total),
                            if (target != null) ...[
                              const SizedBox(height: Gap.md),
                              Text(
                                S.planVersusTarget(target.value),
                                style: context.text.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
              if (list.isNotEmpty) ...[
                const SizedBox(height: Gap.md),
                _AdherenceCard(adherence: adherence),
              ],
              for (final meal in MealType.values)
                MealBlock(
                  title: mealLabel(meal),
                  onAdd: () =>
                      context.push(addFoodLocation(target: 'plan', meal: meal)),
                  lines: [
                    for (final entry in list.where(
                      (entry) => entry.item.meal == meal,
                    ))
                      MealLine(
                        id: entry.item.id,
                        title: entry.food.name,
                        subtitle: S.portionText(
                          Portion(
                            measureLabel: entry.item.measureLabel,
                            measureGrams: entry.item.measureGrams,
                            quantity: entry.item.quantity,
                          ),
                        ),
                        warning: entry.needsReview ? S.planNeedsReview : null,
                        kcal: entry.nutrients.kcal,
                        onTap: () => _edit(context, ref, entry),
                        onDelete: () => _delete(context, ref, entry),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Quantas refeições do plano foram seguidas nos últimos sete dias.
class _AdherenceCard extends StatelessWidget {
  const _AdherenceCard({required this.adherence});

  final PlanAdherence? adherence;

  @override
  Widget build(BuildContext context) {
    final marked = adherence?.marked ?? 0;
    final muted = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gap.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.adherenceTitle, style: context.text.labelLarge),
            const SizedBox(height: Gap.xs),
            if (marked == 0)
              Text(S.adherenceEmpty, style: context.text.bodyMedium)
            else ...[
              Text(
                S.adherenceSummary(adherence!.followed, marked),
                style: context.text.titleMedium,
              ),
              const SizedBox(height: Gap.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: adherence!.rate,
                  minHeight: 8,
                  backgroundColor: context.colors.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: Gap.sm),
              Text(S.adherenceOther(adherence!.other), style: muted),
            ],
          ],
        ),
      ),
    );
  }
}
