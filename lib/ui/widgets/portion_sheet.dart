import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../../data/tables.dart';
import '../../domain/nutrients.dart';
import '../../domain/portion.dart';
import '../../domain/profile_enums.dart';
import '../../providers.dart';
import '../format.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Abre a escolha de porção de um alimento e devolve a porção confirmada.
///
/// Sem [initial], a folha abre na última porção registrada daquele alimento,
/// de preferência em [meal]; se ele nunca foi registrado, na primeira medida
/// caseira ou em 100 g.
Future<Portion?> showPortionSheet(
  BuildContext context, {
  required String? foodId,
  required String foodName,
  required Nutrients per100,
  Portion? initial,
  MealType? meal,
  required String actionLabel,
}) => showModalBottomSheet<Portion>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  useRootNavigator: true,
  builder: (context) => _PortionSheet(
    foodId: foodId,
    foodName: foodName,
    per100: per100,
    initial: initial,
    meal: meal,
    actionLabel: actionLabel,
  ),
);

/// Uma medida que pode ser escolhida na folha.
class _Option {
  const _Option({required this.label, required this.grams, this.userMeasureId});

  static const gram = _Option(label: Portion.gramLabel, grams: 1);

  final String label;
  final double grams;

  /// Preenchido quando a medida foi criada pelo usuário e pode ser removida.
  final String? userMeasureId;

  bool get isGram => label == Portion.gramLabel && grams == 1;

  bool matches(Portion portion) =>
      portion.measureLabel == label && portion.measureGrams == grams;

  @override
  bool operator ==(Object other) =>
      other is _Option &&
      other.label == label &&
      other.grams == grams &&
      other.userMeasureId == userMeasureId;

  @override
  int get hashCode => Object.hash(label, grams, userMeasureId);
}

class _PortionSheet extends ConsumerStatefulWidget {
  const _PortionSheet({
    required this.foodId,
    required this.foodName,
    required this.per100,
    required this.initial,
    required this.meal,
    required this.actionLabel,
  });

  final String? foodId;
  final String foodName;
  final Nutrients per100;
  final Portion? initial;

  /// A refeição em montagem, cuja última porção tem preferência.
  final MealType? meal;
  final String actionLabel;

  @override
  ConsumerState<_PortionSheet> createState() => _PortionSheetState();
}

class _PortionSheetState extends ConsumerState<_PortionSheet> {
  final _quantity = TextEditingController();
  List<_Option> _options = const [_Option.gram];
  _Option _selected = _Option.gram;
  bool _loading = true;
  bool _canAddMeasure = false;

  /// A TACO não informa a energia deste alimento: mostrar "0 kcal" seria
  /// afirmar algo que a fonte não diz.
  bool _energyUnknown = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  Future<List<_Option>> _loadOptions() async {
    final foodId = widget.foodId;
    if (foodId == null) return const [_Option.gram];
    final measures = await ref.read(measureRepositoryProvider).forFood(foodId);
    return [
      _Option.gram,
      for (final measure in measures)
        _Option(
          label: measure.label,
          grams: measure.grams,
          userMeasureId: measure.source == MeasureSource.user
              ? measure.id
              : null,
        ),
    ];
  }

  Future<void> _load() async {
    final foodId = widget.foodId;
    // Os repositórios são lidos antes das esperas: se a folha for fechada no
    // meio do carregamento, `ref` já não pode ser usado.
    final foods = ref.read(foodRepositoryProvider);
    final diary = ref.read(diaryRepositoryProvider);
    final options = await _loadOptions();
    var start = widget.initial;
    FoodRow? food;
    if (foodId != null) {
      food = await foods.byId(foodId);
      if (start == null) {
        final last = await diary.lastForFood(foodId, meal: widget.meal);
        if (last != null) {
          start = Portion(
            measureLabel: last.measureLabel,
            measureGrams: last.measureGrams,
            quantity: last.quantity,
          );
        }
      }
    }
    start ??= options.length > 1
        ? Portion(
            measureLabel: options[1].label,
            measureGrams: options[1].grams,
            quantity: 1,
          )
        : const Portion.grams(100);

    // A porção inicial pode usar uma medida que já não está na lista (por
    // exemplo, uma medida do usuário removida depois). Ela continua valendo.
    var selected = options
        .where((option) => option.matches(start!))
        .firstOrNull;
    final all = [...options];
    if (selected == null) {
      selected = _Option(label: start.measureLabel, grams: start.measureGrams);
      all.add(selected);
    }
    if (!mounted) return;
    setState(() {
      _options = all;
      _selected = selected!;
      _quantity.text = formatForInput(start!.quantity);
      _canAddMeasure = food != null && food.isActive;
      _energyUnknown = food != null && food.isEnergyUnknown;
      _loading = false;
    });
  }

  double? get _quantityValue => parseDecimal(_quantity.text);

  Portion? get _portion {
    final quantity = _quantityValue;
    if (quantity == null) return null;
    final portion = Portion(
      measureLabel: _selected.label,
      measureGrams: _selected.grams,
      quantity: quantity,
    );
    return portion.isValid ? portion : null;
  }

  void _select(_Option option) {
    if (option == _selected) return;
    final grams = _portion?.grams;
    setState(() {
      // Ao voltar para gramas, mantém a quantidade que estava escolhida.
      _quantity.text = option.isGram && grams != null
          ? formatForInput(grams)
          : (option.isGram ? '100' : '1');
      _selected = option;
    });
  }

  /// Em gramas, o passo é 10. Em medidas, o passo é 1, com meia medida entre
  /// zero e um: de 1 diminui para 0,5, e de 0,5 aumenta para 1.
  void _step(int direction) {
    final current = _quantityValue ?? 0;
    final double next;
    if (_selected.isGram) {
      next = current + direction * 10;
    } else if (direction < 0) {
      next = current > 1 ? (current - 1 < 1 ? 1 : current - 1) : current - 0.5;
    } else {
      next = current < 1 ? current + 0.5 : current + 1;
    }
    setState(() => _quantity.text = formatForInput(next < 0 ? 0 : next));
  }

  Future<void> _addMeasure() async {
    final created = await showDialog<({String label, double grams})>(
      context: context,
      builder: (context) => const _NewMeasureDialog(),
    );
    if (created == null || !mounted) return;
    await ref
        .read(measureRepositoryProvider)
        .addUserMeasure(
          foodId: widget.foodId!,
          label: created.label,
          grams: created.grams,
        );
    final options = await _loadOptions();
    if (!mounted) return;
    setState(() {
      _options = options;
      _selected = options.lastWhere(
        (option) =>
            option.label == created.label && option.grams == created.grams,
        orElse: () => _Option.gram,
      );
      _quantity.text = '1';
    });
  }

  Future<void> _removeMeasure(_Option option) async {
    final confirmed = await confirmAction(
      context,
      title: S.removeMeasureTitle(option.label),
      message: S.removeMeasureMessage,
      confirmLabel: S.remove,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await ref
        .read(measureRepositoryProvider)
        .deactivateUserMeasure(option.userMeasureId!);
    final options = await _loadOptions();
    if (!mounted) return;
    setState(() {
      _options = options;
      if (_selected == option) {
        final grams = _portion?.grams ?? 100;
        _selected = _Option.gram;
        _quantity.text = formatForInput(grams);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final portion = _portion;
    final nutrients = widget.per100.forGrams(portion?.grams ?? 0);
    final foodId = widget.foodId;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.foodName, style: context.text.titleLarge),
                      const SizedBox(height: Gap.xs),
                      Text(
                        S.kcalPer100(
                          _energyUnknown ? null : widget.per100.kcal,
                        ),
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (foodId != null && _canAddMeasure) ...[
                  IconButton(
                    onPressed: () => context.push('/food/view/$foodId'),
                    icon: const Icon(Icons.table_rows_outlined),
                    tooltip: S.foodSheet,
                  ),
                  _FavoriteButton(foodId: foodId),
                ],
              ],
            ),
            const SizedBox(height: Gap.lg),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: Gap.xl),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              Wrap(
                spacing: Gap.sm,
                runSpacing: Gap.xs,
                children: [
                  for (final option in _options)
                    InputChip(
                      label: Text(
                        option.isGram
                            ? S.gramsMeasure
                            : S.measureChip(option.label, option.grams),
                      ),
                      selected: option == _selected,
                      showCheckmark: false,
                      onSelected: (_) => _select(option),
                      onDeleted: option.userMeasureId == null
                          ? null
                          : () => _removeMeasure(option),
                      deleteButtonTooltipMessage: S.remove,
                    ),
                  if (_canAddMeasure)
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text(S.myPortion),
                      onPressed: _addMeasure,
                    ),
                ],
              ),
              const SizedBox(height: Gap.lg),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => _step(-1),
                    icon: const Icon(Icons.remove),
                    tooltip: S.less,
                  ),
                  const SizedBox(width: Gap.sm),
                  Expanded(
                    child: TextField(
                      controller: _quantity,
                      textAlign: TextAlign.center,
                      style: context.text.headlineSmall,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: _selected.isGram ? S.grams : S.quantity,
                        errorText:
                            _quantity.text.trim().isNotEmpty && portion == null
                            ? S.invalidQuantity
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: Gap.sm),
                  IconButton.filledTonal(
                    onPressed: () => _step(1),
                    icon: const Icon(Icons.add),
                    tooltip: S.more,
                  ),
                ],
              ),
              const SizedBox(height: Gap.lg),
              _Preview(
                nutrients: nutrients,
                grams: _selected.isGram ? null : portion?.grams,
                energyUnknown: _energyUnknown,
              ),
              if (_energyUnknown) ...[
                const SizedBox(height: Gap.md),
                const InfoBanner(S.energyUnknownNote),
              ],
              const SizedBox(height: Gap.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: portion == null
                      ? null
                      : () => Navigator.of(context).pop(portion),
                  child: Text(widget.actionLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.nutrients,
    required this.grams,
    required this.energyUnknown,
  });

  /// Quando verdadeiro, a energia aparece como não informada, não como zero.
  final bool energyUnknown;

  final Nutrients nutrients;

  /// Gramatura equivalente, exibida quando a medida não é o grama.
  final double? grams;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // A cor identifica o macronutriente em um marcador; o texto usa as
    // cores de texto do tema.
    Widget macro(String label, double value, Color color) => Expanded(
      child: Column(
        children: [
          Text(formatGrams(value), style: context.text.titleMedium),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: Gap.xs),
              Flexible(child: Text(label, style: context.text.labelSmall)),
            ],
          ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(Corner.md),
      ),
      child: Column(
        children: [
          Text(
            energyUnknown ? S.energyUnknown : formatKcal(nutrients.kcal),
            style: context.text.headlineSmall,
          ),
          if (grams != null)
            Text(
              S.equalsGrams(grams!),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              macro(S.protein, nutrients.protein, colors.protein),
              macro(S.carb, nutrients.carb, colors.carb),
              macro(S.fat, nutrients.fat, colors.fat),
            ],
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.foodId});

  final String foodId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = ref.watch(isFavoriteProvider(foodId)).value ?? false;
    return IconButton(
      onPressed: () => ref
          .read(foodRepositoryProvider)
          .setFavorite(foodId, favorite: !favorite),
      icon: Icon(favorite ? Icons.star : Icons.star_border),
      color: favorite ? context.colors.primary : null,
      tooltip: favorite ? S.removeFavorite : S.addFavorite,
    );
  }
}

class _NewMeasureDialog extends StatefulWidget {
  const _NewMeasureDialog();

  @override
  State<_NewMeasureDialog> createState() => _NewMeasureDialogState();
}

class _NewMeasureDialogState extends State<_NewMeasureDialog> {
  final _form = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _grams = TextEditingController();

  @override
  void dispose() {
    _label.dispose();
    _grams.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context)
        .pop((label: _label.text.trim(), grams: parseDecimal(_grams.text)!));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(S.myPortion),
      scrollable: true,
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.myPortionHelp, style: context.text.bodyMedium),
            const SizedBox(height: Gap.md),
            Wrap(
              spacing: Gap.xs,
              runSpacing: Gap.xs,
              children: [
                for (final name in S.portionNameSuggestions)
                  ActionChip(
                    label: Text(name),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _label.text = name),
                  ),
              ],
            ),
            const SizedBox(height: Gap.md),
            TextFormField(
              controller: _label,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: S.portionName,
                hintText: S.portionNameHint,
              ),
              validator: (text) =>
                  (text ?? '').trim().isEmpty ? S.requiredField : null,
            ),
            const SizedBox(height: Gap.md),
            DecimalField(
              controller: _grams,
              label: S.portionWeight,
              suffix: 'g',
              required: true,
              allowZero: false,
              max: 5000,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(S.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
          onPressed: _save,
          child: const Text(S.save),
        ),
      ],
    );
  }
}
