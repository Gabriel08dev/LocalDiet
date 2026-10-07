import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/meal_text_resolver.dart';
import '../../domain/meal_text_parser.dart';
import '../../domain/portion.dart';
import '../../domain/preparation.dart';
import '../../providers.dart';
import '../format.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Uma linha da proposta do parser, editável pelo usuário.
class _Line {
  _Line({
    required this.source,
    required this.candidates,
    required this.food,
    this.portion,
    this.parsed,
    this.owner,
  }) : grams = TextEditingController(
         text: portion == null ? '' : formatForInput(portion.grams),
       );

  /// O trecho do texto que originou a linha.
  final String source;
  final List<FoodRow> candidates;
  FoodRow? food;
  final TextEditingController grams;
  final ParsedMealItem? parsed;

  /// A porção proposta, na medida em que foi dita.
  Portion? portion;

  /// A porção que será salva: a proposta, enquanto os gramas não forem
  /// alterados à mão; depois disso, os gramas digitados.
  Portion? get chosenPortion {
    final typed = gramsValue;
    if (typed == null) return null;
    final proposed = portion;
    if (proposed != null && (proposed.grams - typed).abs() < 0.005) {
      return proposed;
    }
    return Portion.grams(typed);
  }

  /// Preenchido nas linhas de óleo: o item preparado que gerou a sugestão.
  final _Line? owner;

  bool get isOilEstimate => owner != null;

  double? get gramsValue {
    final value = parseDecimal(grams.text);
    return value == null || value <= 0 ? null : value;
  }

  bool get isReady => food != null && gramsValue != null;
}

/// Entrada secundária de refeição: o usuário descreve o que comeu em texto,
/// o app propõe alimentos e quantidades, e nada segue adiante sem conferência.
class MealTextSheet extends ConsumerStatefulWidget {
  const MealTextSheet({super.key});

  @override
  ConsumerState<MealTextSheet> createState() => _MealTextSheetState();
}

class _MealTextSheetState extends ConsumerState<MealTextSheet> {
  final _text = TextEditingController();
  List<_Line>? _lines;
  FoodRow? _oilFood;
  bool _busy = false;

  MealTextResolver get _resolver => MealTextResolver(
    ref.read(foodRepositoryProvider),
    ref.read(measureRepositoryProvider),
  );

  @override
  void dispose() {
    _text.dispose();
    for (final line in _lines ?? const <_Line>[]) {
      line.grams.dispose();
    }
    super.dispose();
  }

  _Line? _oilLineFor(_Line owner) {
    final preparation = owner.parsed?.preparation;
    final food = owner.food;
    final oil = _oilFood;
    if (preparation == null || food == null || oil == null) return null;
    final grams = suggestedOilGrams(preparation, food.name);
    if (grams == null) return null;
    return _Line(
      source: S.oilEstimateFor(preparationLabel(preparation)),
      candidates: [oil],
      food: oil,
      portion: Portion.grams(grams),
      owner: owner,
    );
  }

  Future<void> _interpret() async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    final resolver = _resolver;
    final resolved = await resolver.resolve(_text.text);
    _oilFood = await resolver.oilFood();
    final lines = <_Line>[];
    for (final item in resolved) {
      final line = _Line(
        source: item.parsed.source,
        candidates: item.candidates,
        food: item.food,
        portion: item.portion,
        parsed: item.parsed,
      );
      lines.add(line);
      final oil = _oilLineFor(line);
      if (oil != null) lines.add(oil);
    }
    if (!mounted) return;
    setState(() {
      _lines = lines;
      _busy = false;
    });
  }

  Future<void> _changeFood(_Line line, FoodRow food) async {
    final lines = _lines!;
    final portion = line.parsed == null
        ? null
        : await _resolver.portionFor(line.parsed!, food);
    if (!mounted) return;
    setState(() {
      line.food = food;
      // A gramatura só é reescrita quando vinha de uma medida do alimento
      // anterior; gramas digitados pelo usuário ou lidos do texto ficam.
      if (line.parsed?.kind == QuantityKind.measure) {
        line.portion = portion;
        line.grams.text = portion == null ? '' : formatForInput(portion.grams);
      }
      lines.removeWhere((other) => other.owner == line);
      final oil = _oilLineFor(line);
      if (oil != null) lines.insert(lines.indexOf(line) + 1, oil);
    });
  }

  void _remove(_Line line) {
    setState(() {
      _lines!.removeWhere((other) => other == line || other.owner == line);
    });
  }

  void _confirm() {
    final portions = [
      for (final line in _lines!)
        FoodPortion(
          foodId: line.food!.id,
          foodName: line.food!.name,
          per100: line.food!.per100,
          portion: line.chosenPortion!,
          isEstimate: line.isOilEstimate,
        ),
    ];
    Navigator.of(context).pop(portions);
  }

  @override
  Widget build(BuildContext context) {
    final lines = _lines;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.describeMeal, style: context.text.titleLarge),
            const SizedBox(height: Gap.md),
            TextField(
              controller: _text,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: S.describeMealHint),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Gap.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: _busy || _text.text.trim().isEmpty
                    ? null
                    : _interpret,
                child: Text(lines == null ? S.interpret : S.interpretAgain),
              ),
            ),
            if (lines != null) ...[
              const SizedBox(height: Gap.lg),
              if (lines.isEmpty)
                const InfoBanner(S.nothingRecognized)
              else ...[
                const InfoBanner(S.parserNotice),
                for (final line in lines)
                  _LineEditor(
                    key: ObjectKey(line),
                    line: line,
                    onFoodChanged: (food) => _changeFood(line, food),
                    onChanged: () => setState(() {}),
                    onRemove: () => _remove(line),
                  ),
                const SizedBox(height: Gap.lg),
                if (!lines.every((line) => line.isReady))
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.sm),
                    child: Text(
                      S.parserIncomplete,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.error,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: lines.every((line) => line.isReady)
                        ? _confirm
                        : null,
                    child: const Text(S.addToMealReview),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// "2 × fatia de 25 g", quando a quantidade veio de uma medida caseira.
String? _measureNote(_Line line) {
  final portion = line.chosenPortion;
  if (portion == null || portion.isInGrams) return null;
  return S.measureNote(portion);
}

class _LineEditor extends StatelessWidget {
  const _LineEditor({
    super.key,
    required this.line,
    required this.onFoodChanged,
    required this.onChanged,
    required this.onRemove,
  });

  final _Line line;
  final ValueChanged<FoodRow> onFoodChanged;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final food = line.food;
    return Padding(
      padding: const EdgeInsets.only(top: Gap.md),
      child: Container(
        padding: const EdgeInsets.fromLTRB(Gap.md, Gap.sm, Gap.xs, Gap.md),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(Corner.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    line.isOilEstimate ? line.source : '"${line.source}"',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                  tooltip: S.remove,
                ),
              ],
            ),
            if (food == null)
              Padding(
                padding: const EdgeInsets.only(right: Gap.sm),
                child: Text(
                  S.parserFoodNotFound,
                  style: TextStyle(color: context.colors.error),
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.only(right: Gap.sm),
                child: line.candidates.length > 1
                    ? DropdownButtonFormField<FoodRow>(
                        key: ValueKey(food.id),
                        initialValue: food,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: S.food),
                        items: [
                          for (final candidate in line.candidates)
                            DropdownMenuItem(
                              value: candidate,
                              child: Text(
                                candidate.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) onFoodChanged(value);
                        },
                      )
                    : Text(food.name, style: context.text.titleMedium),
              ),
              const SizedBox(height: Gap.sm),
              Padding(
                padding: const EdgeInsets.only(right: Gap.sm),
                child: DecimalField(
                  controller: line.grams,
                  label: S.grams,
                  suffix: 'g',
                  allowZero: false,
                  max: 5000,
                  helper: line.gramsValue == null
                      ? S.parserGramsMissing
                      : line.isOilEstimate
                      ? S.oilEstimateHelp
                      : _measureNote(line),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
