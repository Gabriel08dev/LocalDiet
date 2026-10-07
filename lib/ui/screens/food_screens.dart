import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../../data/tables.dart';
import '../../domain/nutrients.dart';
import '../../domain/taco_value.dart';
import '../../providers.dart';
import '../format.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Cria ou edita um alimento do usuário. Ao salvar, devolve o id do alimento.
class CustomFoodScreen extends ConsumerStatefulWidget {
  const CustomFoodScreen({super.key, this.foodId, this.initialName});

  final String? foodId;
  final String? initialName;

  @override
  ConsumerState<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends ConsumerState<CustomFoodScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carb = TextEditingController();
  final _fat = TextEditingController();
  final _fiber = TextEditingController();
  final _sodium = TextEditingController();
  final _portionLabel = TextEditingController();
  final _portionGrams = TextEditingController();
  bool _loading = false;
  bool _saving = false;

  bool get _isEditing => widget.foodId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final food = await ref.read(foodRepositoryProvider).byId(widget.foodId!);
    if (!mounted) return;
    if (food != null) {
      _name.text = food.name;
      _kcal.text = formatForInput(food.per100.kcal);
      _protein.text = formatForInput(food.per100.protein);
      _carb.text = formatForInput(food.per100.carb);
      _fat.text = formatForInput(food.per100.fat);
      _fiber.text = formatForInput(food.per100.fiber);
      _sodium.text = formatForInput(food.per100.sodium);
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _kcal,
      _protein,
      _carb,
      _fat,
      _fiber,
      _sodium,
      _portionLabel,
      _portionGrams,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validatePortionLabel(String? text) {
    final hasLabel = (text ?? '').trim().isNotEmpty;
    final hasGrams = _portionGrams.text.trim().isNotEmpty;
    return hasGrams && !hasLabel ? S.requiredField : null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final portionLabel = _portionLabel.text.trim();
    final portionGrams = parseDecimal(_portionGrams.text);
    if (portionLabel.isNotEmpty && portionGrams == null) {
      showMessage(context, S.portionWeightMissing);
      return;
    }
    setState(() => _saving = true);
    final id = await ref
        .read(foodRepositoryProvider)
        .saveUserFood(
          id: widget.foodId,
          name: _name.text,
          per100: Nutrients(
            kcal: parseDecimal(_kcal.text)!,
            protein: parseDecimal(_protein.text) ?? 0,
            carb: parseDecimal(_carb.text) ?? 0,
            fat: parseDecimal(_fat.text) ?? 0,
            fiber: parseDecimal(_fiber.text) ?? 0,
            sodium: parseDecimal(_sodium.text) ?? 0,
          ),
        );
    if (portionLabel.isNotEmpty && portionGrams != null) {
      await ref
          .read(measureRepositoryProvider)
          .addUserMeasure(foodId: id, label: portionLabel, grams: portionGrams);
    }
    if (!mounted) return;
    showMessage(context, S.foodSaved);
    context.pop(id);
  }

  Future<void> _deactivate() async {
    final confirmed = await confirmAction(
      context,
      title: S.deactivateFoodTitle,
      message: S.deactivateFoodMessage,
      confirmLabel: S.remove,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await ref.read(foodRepositoryProvider).deactivateUserFood(widget.foodId!);
    if (!mounted) return;
    showMessage(context, S.foodRemoved);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? S.editFood : S.createFood),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _deactivate,
              icon: const Icon(Icons.delete_outline),
              tooltip: S.remove,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Gap.lg,
                  Gap.sm,
                  Gap.lg,
                  Gap.xxl,
                ),
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: S.foodName),
                    validator: (text) =>
                        (text ?? '').trim().isEmpty ? S.requiredField : null,
                  ),
                  const SizedBox(height: Gap.lg),
                  Text(S.per100g, style: context.text.titleMedium),
                  const SizedBox(height: Gap.xs),
                  Text(
                    S.per100gHelp,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Gap.md),
                  DecimalField(
                    controller: _kcal,
                    label: S.energy,
                    suffix: S.kcalUnit,
                    required: true,
                    max: 900,
                  ),
                  const SizedBox(height: Gap.md),
                  DecimalField(
                    controller: _protein,
                    label: S.protein,
                    suffix: 'g',
                    max: 100,
                  ),
                  const SizedBox(height: Gap.md),
                  DecimalField(
                    controller: _carb,
                    label: S.carb,
                    suffix: 'g',
                    max: 100,
                  ),
                  const SizedBox(height: Gap.md),
                  DecimalField(
                    controller: _fat,
                    label: S.fat,
                    suffix: 'g',
                    max: 100,
                  ),
                  const SizedBox(height: Gap.md),
                  DecimalField(
                    controller: _fiber,
                    label: S.fiber,
                    suffix: 'g',
                    max: 100,
                  ),
                  const SizedBox(height: Gap.md),
                  DecimalField(
                    controller: _sodium,
                    label: S.sodium,
                    suffix: 'mg',
                    max: 100000,
                  ),
                  if (!_isEditing) ...[
                    const SizedBox(height: Gap.xl),
                    Text(S.usualPortion, style: context.text.titleMedium),
                    const SizedBox(height: Gap.xs),
                    Text(
                      S.usualPortionHelp,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Gap.md),
                    TextFormField(
                      controller: _portionLabel,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: S.portionName,
                        hintText: S.portionNameHint,
                      ),
                      validator: _validatePortionLabel,
                    ),
                    const SizedBox(height: Gap.md),
                    DecimalField(
                      controller: _portionGrams,
                      label: S.portionWeight,
                      suffix: 'g',
                      allowZero: false,
                      max: 5000,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                  const SizedBox(height: Gap.xl),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: const Text(S.save),
                  ),
                ],
              ),
            ),
    );
  }
}

class MyFoodsScreen extends ConsumerWidget {
  const MyFoodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foods = ref.watch(userFoodsProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text(S.myFoods)),
      body: foods == null
          ? const Center(child: CircularProgressIndicator())
          : foods.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.restaurant_outlined,
                title: S.noUserFoods,
                message: S.noUserFoodsHelp,
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                for (final food in foods)
                  ListTile(
                    title: Text(food.name),
                    subtitle: Text(S.kcalPer100(food.per100.kcal)),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => context.push('/food/edit/${food.id}'),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push('/food/new'),
        icon: const Icon(Icons.add),
        label: const Text(S.createFood),
      ),
    );
  }
}

/// Nutrientes da ficha, na ordem em que a TACO os publica.
const _sheetRows = [
  ('energy_kcal', 'Energia', 'kcal'),
  ('energy_kj', 'Energia', 'kJ'),
  ('protein_g', 'Proteína', 'g'),
  ('lipid_g', 'Lipídeos', 'g'),
  ('cholesterol_mg', 'Colesterol', 'mg'),
  ('carb_g', 'Carboidrato', 'g'),
  ('fiber_g', 'Fibra alimentar', 'g'),
  ('ash_g', 'Cinzas', 'g'),
  ('moisture_pct', 'Umidade', '%'),
  ('calcium_mg', 'Cálcio', 'mg'),
  ('magnesium_mg', 'Magnésio', 'mg'),
  ('manganese_mg', 'Manganês', 'mg'),
  ('phosphorus_mg', 'Fósforo', 'mg'),
  ('iron_mg', 'Ferro', 'mg'),
  ('sodium_mg', 'Sódio', 'mg'),
  ('potassium_mg', 'Potássio', 'mg'),
  ('copper_mg', 'Cobre', 'mg'),
  ('zinc_mg', 'Zinco', 'mg'),
  ('retinol_mcg', 'Retinol', 'µg'),
  ('re_mcg', 'RE', 'µg'),
  ('rae_mcg', 'RAE', 'µg'),
  ('thiamine_mg', 'Tiamina', 'mg'),
  ('riboflavin_mg', 'Riboflavina', 'mg'),
  ('pyridoxine_mg', 'Piridoxina', 'mg'),
  ('niacin_mg', 'Niacina', 'mg'),
  ('vitamin_c_mg', 'Vitamina C', 'mg'),
];

/// Como um valor da TACO aparece na ficha: o número com a unidade ou o
/// símbolo original. Nunca "0" no lugar de um valor desconhecido.
String _display(TacoValue value, String unit) => switch (value) {
  TacoNumber(:final value) => '${formatPrecise(value)} $unit',
  TacoTrace() => 'Tr',
  TacoNotApplicable() => 'NA',
  TacoUnderReview() => '*',
  TacoMissing() => '—',
};

/// Ficha do alimento: todos os nutrientes por 100 g.
class FoodDetailScreen extends ConsumerWidget {
  const FoodDetailScreen({super.key, required this.foodId});

  final String foodId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(S.foodSheet)),
      body: FutureBuilder<FoodRow?>(
        future: ref.watch(foodRepositoryProvider).byId(foodId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final food = snapshot.data;
          if (food == null) {
            return const Center(
              child: EmptyState(icon: Icons.search_off, title: S.foodNotFound),
            );
          }
          return _FoodSheet(food: food);
        },
      ),
    );
  }
}

class _FoodSheet extends StatelessWidget {
  const _FoodSheet({required this.food});

  final FoodRow food;

  List<(String, String)> _rows() {
    if (food.source == FoodSource.user || food.nutrientsJson == null) {
      final values = food.per100;
      return [
        ('Energia', '${formatPrecise(values.kcal)} kcal'),
        ('Proteína', '${formatPrecise(values.protein)} g'),
        ('Carboidrato', '${formatPrecise(values.carb)} g'),
        ('Lipídeos', '${formatPrecise(values.fat)} g'),
        ('Fibra alimentar', '${formatPrecise(values.fiber)} g'),
        ('Sódio', '${formatPrecise(values.sodium)} mg'),
      ];
    }
    final raw = jsonDecode(food.nutrientsJson!) as Map<String, dynamic>;
    return [
      for (final (key, label, unit) in _sheetRows)
        (label, _display(TacoValue.fromRaw(raw[key]), unit)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isTaco = food.source == FoodSource.taco;
    final muted = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
      children: [
        Text(food.name, style: context.text.titleLarge),
        const SizedBox(height: Gap.xs),
        Text(
          isTaco ? S.tacoFoodSource(food.tacoNumber, food.category) : S.myFood,
          style: muted,
        ),
        const SizedBox(height: Gap.lg),
        Text(S.per100g, style: context.text.labelLarge),
        const SizedBox(height: Gap.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.sm),
            child: Column(
              children: [
                for (final (label, value) in _rows())
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Gap.lg,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(label)),
                        const SizedBox(width: Gap.md),
                        Text(value, style: context.text.titleSmall),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (isTaco) ...[
          const SizedBox(height: Gap.md),
          Text(S.tacoLegend, style: muted),
        ] else ...[
          const SizedBox(height: Gap.md),
          OutlinedButton.icon(
            onPressed: () => context.push('/food/edit/${food.id}'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text(S.editFood),
          ),
        ],
      ],
    );
  }
}
