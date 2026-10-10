import 'dart:async';

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
import 'meal_text_sheet.dart';

/// Para onde vão os alimentos escolhidos.
enum AddTarget { diary, plan }

/// Monta uma refeição: busca, escolha de porção, revisão e gravação.
///
/// Nada é salvo até o usuário confirmar na revisão. A gravação é feita de
/// uma vez, em transação, pelo repositório.
class MealBuilderScreen extends ConsumerStatefulWidget {
  const MealBuilderScreen({
    super.key,
    required this.target,
    required this.meal,
    required this.date,
  });

  final AddTarget target;
  final MealType meal;
  final LocalDate date;

  @override
  ConsumerState<MealBuilderScreen> createState() => _MealBuilderScreenState();
}

class _MealBuilderScreenState extends ConsumerState<MealBuilderScreen> {
  late MealType _meal = widget.meal;
  final _draft = <FoodPortion>[];
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  Future<List<FoodRow>>? _results;
  bool _reviewing = false;
  bool _saving = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQueryChanged(String text) {
    _debounce?.cancel();
    final query = text.trim();
    if (query.isEmpty) {
      // Apagar a busca volta às sugestões na hora, sem esperar o debounce.
      setState(() {
        _query = '';
        _results = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _query = query;
        _results = ref.read(foodRepositoryProvider).search(query);
      });
    });
  }

  Future<void> _pick(FoodRow food) async {
    final portion = await showPortionSheet(
      context,
      foodId: food.id,
      foodName: food.name,
      per100: food.per100,
      meal: _meal,
      actionLabel: S.add,
    );
    if (portion == null || !mounted) return;
    _search.clear();
    _onQueryChanged('');
    setState(
      () => _draft.add(
        FoodPortion(
          foodId: food.id,
          foodName: food.name,
          per100: food.per100,
          portion: portion,
        ),
      ),
    );
  }

  Future<void> _editDraft(int index) async {
    final item = _draft[index];
    final portion = await showPortionSheet(
      context,
      foodId: item.foodId,
      foodName: item.foodName,
      per100: item.per100,
      initial: item.portion,
      actionLabel: S.save,
    );
    if (portion == null || !mounted) return;
    setState(() => _draft[index] = item.withPortion(portion));
  }

  Future<void> _createFood() async {
    final location = Uri(
      path: '/food/new',
      queryParameters: _query.isEmpty ? null : {'name': _query},
    ).toString();
    final id = await context.push<String>(location);
    if (id == null || !mounted) return;
    final food = await ref.read(foodRepositoryProvider).byId(id);
    if (food != null && mounted) await _pick(food);
  }

  Future<void> _describe() async {
    final items = await showModalBottomSheet<List<FoodPortion>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (context) => const MealTextSheet(),
    );
    if (items == null || items.isEmpty || !mounted) return;
    setState(() {
      _draft.addAll(items);
      _reviewing = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      switch (widget.target) {
        case AddTarget.diary:
          await ref
              .read(diaryRepositoryProvider)
              .addItems(widget.date, _meal, _draft);
        case AddTarget.plan:
          await ref.read(planRepositoryProvider).addItems(_meal, _draft);
      }
      if (!mounted) return;
      showMessage(
        context,
        widget.target == AddTarget.diary ? S.mealSaved : S.planSaved,
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessage(context, S.saveFailed);
    }
  }

  Future<void> _handleBack() async {
    if (_reviewing) {
      setState(() => _reviewing = false);
      return;
    }
    final discard = await confirmAction(
      context,
      title: S.discardMealTitle,
      message: S.discardMealMessage,
      confirmLabel: S.discard,
      destructive: true,
    );
    if (discard && mounted) context.pop();
  }

  String get _title {
    final base = widget.target == AddTarget.diary ? S.diary : S.plan;
    if (widget.target == AddTarget.plan) return base;
    final today = ref.read(todayProvider);
    return '$base · ${formatRelativeDay(widget.date, today)}';
  }

  @override
  Widget build(BuildContext context) {
    final total = Nutrients.sum(_draft.map((item) => item.nutrients));
    return PopScope(
      canPop: !_reviewing && _draft.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_reviewing ? S.reviewMeal : _title)),
        body: _reviewing ? _buildReview(total) : _buildSearch(),
        bottomNavigationBar: _draft.isEmpty
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Gap.lg,
                    Gap.sm,
                    Gap.lg,
                    Gap.md,
                  ),
                  child: _reviewing
                      ? FilledButton(
                          onPressed: _saving ? null : _save,
                          child: Text(
                            widget.target == AddTarget.diary
                                ? S.saveToDiary(mealLabel(_meal))
                                : S.saveToPlan(mealLabel(_meal)),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Text(
                                S.itemsAndKcal(_draft.length, total.kcal),
                                style: context.text.titleMedium,
                              ),
                            ),
                            const SizedBox(width: Gap.md),
                            FilledButton(
                              onPressed: () =>
                                  setState(() => _reviewing = true),
                              child: const Text(S.review),
                            ),
                          ],
                        ),
                ),
              ),
      ),
    );
  }

  Widget _buildMealChips() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
    child: Row(
      children: [
        for (final meal in MealType.values)
          Padding(
            padding: const EdgeInsets.only(right: Gap.sm),
            child: ChoiceChip(
              label: Text(mealLabel(meal)),
              selected: meal == _meal,
              onSelected: (_) => setState(() => _meal = meal),
            ),
          ),
      ],
    ),
  );

  Widget _buildSearch() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.md),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: S.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _search.clear();
                        _onQueryChanged('');
                      },
                      icon: const Icon(Icons.close),
                      tooltip: S.clear,
                    ),
            ),
            onChanged: (text) {
              setState(() {});
              _onQueryChanged(text);
            },
          ),
        ),
        _buildMealChips(),
        const SizedBox(height: Gap.sm),
        Expanded(
          child: _query.isEmpty
              ? _Suggestions(
                  meal: _meal,
                  onPick: _pick,
                  onDescribe: _describe,
                  onCreate: _createFood,
                )
              : FutureBuilder<List<FoodRow>>(
                  future: _results,
                  builder: (context, snapshot) {
                    final foods = snapshot.data;
                    if (foods == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (foods.isEmpty) {
                      return SingleChildScrollView(
                        child: EmptyState(
                          icon: Icons.search_off,
                          title: S.noFoodFound,
                          message: S.noFoodFoundHelp,
                          action: OutlinedButton.icon(
                            onPressed: _createFood,
                            icon: const Icon(Icons.add),
                            label: Text(S.createFoodNamed(_query)),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: foods.length,
                      itemBuilder: (context, index) =>
                          FoodTile(food: foods[index], onTap: _pick),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReview(Nutrients total) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xl),
      children: [
        _buildMealChipsInset(),
        const SizedBox(height: Gap.md),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (index, item) in _draft.indexed)
                ListTile(
                  title: Text(item.foodName),
                  subtitle: Text(
                    item.isEstimate
                        ? '${S.portionText(item.portion)} · ${S.estimate}'
                        : S.portionText(item.portion),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatInteger(item.nutrients.kcal),
                        style: context.text.titleMedium,
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          _draft.removeAt(index);
                          if (_draft.isEmpty) _reviewing = false;
                        }),
                        icon: const Icon(Icons.close),
                        tooltip: S.remove,
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.only(left: Gap.lg),
                  onTap: () => _editDraft(index),
                ),
            ],
          ),
        ),
        const SizedBox(height: Gap.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Gap.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.mealTotal, style: context.text.labelLarge),
                const SizedBox(height: Gap.xs),
                Text(formatKcal(total.kcal), style: context.text.headlineSmall),
                const SizedBox(height: Gap.xs),
                MacroLine(total),
              ],
            ),
          ),
        ),
        const SizedBox(height: Gap.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _reviewing = false),
            icon: const Icon(Icons.add),
            label: const Text(S.addMoreFoods),
          ),
        ),
      ],
    );
  }

  /// As opções de refeição dentro de uma lista que já tem margem lateral.
  Widget _buildMealChipsInset() => Wrap(
    spacing: Gap.sm,
    runSpacing: Gap.xs,
    children: [
      for (final meal in MealType.values)
        ChoiceChip(
          label: Text(mealLabel(meal)),
          selected: meal == _meal,
          onSelected: (_) => setState(() => _meal = meal),
        ),
    ],
  );
}

/// Linha de um alimento em listas de busca e sugestões.
class FoodTile extends StatelessWidget {
  const FoodTile({super.key, required this.food, required this.onTap});

  final FoodRow food;
  final ValueChanged<FoodRow> onTap;

  @override
  Widget build(BuildContext context) {
    final kcal = S.kcalPer100(food.isEnergyUnknown ? null : food.per100.kcal);
    final isMine = food.source == FoodSource.user;
    return ListTile(
      leading: IconBadge(foodIcon(food), tone: foodTone(context, food)),
      title: Text(food.name),
      subtitle: Text(isMine ? '$kcal · ${S.myFood}' : kcal),
      trailing: Icon(Icons.add_circle, color: context.colors.primary),
      onTap: () => onTap(food),
    );
  }
}

/// O tom pastel do grupo do alimento.
Tone foodTone(BuildContext context, FoodRow food) {
  final colors = context.appColors;
  if (food.source == FoodSource.user) return colors.lavender;
  final category = food.category ?? '';
  if (category.startsWith('Verduras')) return colors.mint;
  if (category.startsWith('Leguminosas')) return colors.mint;
  if (category.startsWith('Frutas')) return colors.pink;
  if (category.startsWith('Produtos açucarados')) return colors.pink;
  if (category.startsWith('Carnes')) return colors.peach;
  if (category.startsWith('Nozes')) return colors.peach;
  if (category.startsWith('Pescados')) return colors.sky;
  if (category.startsWith('Leite')) return colors.sky;
  if (category.startsWith('Bebidas')) return colors.lavender;
  if (category.startsWith('Alimentos preparados')) return colors.lavender;
  return colors.lemon;
}

/// Ícone do grupo do alimento na TACO, para reconhecer o tipo de relance.
IconData foodIcon(FoodRow food) {
  if (food.source == FoodSource.user) return Icons.bookmark_outline;
  final category = food.category ?? '';
  if (category.startsWith('Cereais')) return Icons.bakery_dining_outlined;
  if (category.startsWith('Verduras')) return Icons.eco_outlined;
  if (category.startsWith('Frutas')) return Icons.spa_outlined;
  if (category.startsWith('Gorduras')) return Icons.water_drop_outlined;
  if (category.startsWith('Pescados')) return Icons.set_meal_outlined;
  if (category.startsWith('Carnes')) return Icons.kebab_dining_outlined;
  if (category.startsWith('Leite')) return Icons.local_drink_outlined;
  if (category.startsWith('Bebidas')) return Icons.local_cafe_outlined;
  if (category.startsWith('Ovos')) return Icons.egg_outlined;
  if (category.startsWith('Produtos açucarados')) return Icons.cake_outlined;
  if (category.startsWith('Leguminosas')) return Icons.grain;
  if (category.startsWith('Nozes')) return Icons.grain;
  if (category.startsWith('Alimentos preparados')) {
    return Icons.ramen_dining_outlined;
  }
  return Icons.restaurant_outlined;
}

/// O que aparece antes de o usuário digitar: atalhos e alimentos já usados
/// na refeição em montagem.
///
/// Recentes e mais usados são de [meal]: o histórico do almoço não aparece
/// no café da manhã. Os favoritos valem para todas as refeições.
class _Suggestions extends ConsumerWidget {
  const _Suggestions({
    required this.meal,
    required this.onPick,
    required this.onDescribe,
    required this.onCreate,
  });

  final MealType meal;
  final ValueChanged<FoodRow> onPick;
  final VoidCallback onDescribe;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteFoodsProvider).value ?? const [];
    final recents = ref.watch(recentFoodsProvider(meal)).value ?? const [];
    final used = ref.watch(frequentFoodsProvider(meal)).value ?? const [];
    final shown = {...favorites, ...recents}.map((food) => food.id).toSet();
    final frequents = used.where((food) => !shown.contains(food.id)).toList();
    final nothingYet = favorites.isEmpty && recents.isEmpty;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
          child: Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.xs,
            children: [
              ActionChip(
                avatar: const Icon(Icons.notes, size: 18),
                label: const Text(S.describeMeal),
                onPressed: onDescribe,
              ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text(S.createFood),
                onPressed: onCreate,
              ),
            ],
          ),
        ),
        if (favorites.isNotEmpty) ...[
          const SectionHeader(S.favorites),
          for (final food in favorites) FoodTile(food: food, onTap: onPick),
        ],
        if (recents.isNotEmpty) ...[
          SectionHeader(S.recentsIn(meal)),
          for (final food in recents) FoodTile(food: food, onTap: onPick),
        ],
        if (frequents.isNotEmpty) ...[
          SectionHeader(S.frequentsIn(meal)),
          for (final food in frequents) FoodTile(food: food, onTap: onPick),
        ],
        if (nothingYet)
          const Padding(
            padding: EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 0),
            child: InfoBanner(S.searchIntro, icon: Icons.lightbulb_outline),
          )
        else if (recents.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 0),
            child: InfoBanner(S.noRecentsIn(meal)),
          ),
        const SizedBox(height: Gap.xl),
      ],
    );
  }
}
