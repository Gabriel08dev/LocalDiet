import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../domain/body_metrics.dart';
import '../../domain/local_date.dart';
import '../../providers.dart';
import '../format.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/trend_chart.dart';

/// Uma das medidas corporais acompanhadas.
class _Metric {
  const _Metric(this.label, this.unit, this.read);

  final String label;
  final String unit;
  final double? Function(BodyMeasurementRow row) read;

  List<TrendPoint> points(List<BodyMeasurementRow> rows) => [
    for (final row in rows)
      if (read(row) != null) TrendPoint(row.date, read(row)!),
  ];
}

final _metrics = [
  _Metric(S.weight, 'kg', (row) => row.weightKg),
  _Metric(S.waist, 'cm', (row) => row.waistCm),
  _Metric(S.neck, 'cm', (row) => row.neckCm),
  _Metric(S.hip, 'cm', (row) => row.hipCm),
];

class EvolutionScreen extends ConsumerWidget {
  const EvolutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurements = ref.watch(measurementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(S.evolution)),
      body: measurements.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            const EmptyState(icon: Icons.error_outline, title: S.loadFailed),
        data: (rows) => rows.isEmpty
            ? const Center(
                child: EmptyState(
                  icon: Icons.monitor_weight_outlined,
                  title: S.noMeasurements,
                  message: S.noMeasurementsHelp,
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, 96),
                children: [
                  _Indicators(rows: rows),
                  for (final metric in _metrics)
                    _MetricCard(metric: metric, rows: rows),
                  const SectionHeader(S.history),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (final row in rows.reversed)
                          ListTile(
                            title: Text(formatDate(row.date)),
                            subtitle: Text(S.measurementSummary(row)),
                            trailing: const Icon(Icons.edit_outlined),
                            onTap: () =>
                                showMeasurementSheet(context, existing: row),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => showMeasurementSheet(context),
        icon: const Icon(Icons.add),
        label: const Text(S.newMeasurement),
      ),
    );
  }
}

/// Peso atual, IMC e gordura corporal estimada.
class _Indicators extends ConsumerWidget {
  const _Indicators({required this.rows});

  final List<BodyMeasurementRow> rows;

  double? _latest(double? Function(BodyMeasurementRow row) read) {
    for (final row in rows.reversed) {
      final value = read(row);
      if (value != null) return value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final weight = _latest((row) => row.weightKg);
    final weights = _metrics.first.points(rows);
    final bmi = profile == null || weight == null
        ? null
        : bodyMassIndex(weightKg: weight, heightCm: profile.heightCm);
    final bodyFat = profile == null
        ? null
        : navyBodyFatPercent(
            sex: profile.sex,
            heightCm: profile.heightCm,
            waistCm: _latest((row) => row.waistCm),
            neckCm: _latest((row) => row.neckCm),
            hipCm: _latest((row) => row.hipCm),
          );

    final muted = context.colors.onSurfaceVariant;
    Widget tile(IconData icon, String label, String value, [String? note]) =>
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Gap.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: muted),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        style: context.text.labelMedium?.copyWith(color: muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.sm),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: context.text.titleLarge),
                ),
                if (note != null)
                  Text(
                    note,
                    style: context.text.bodySmall?.copyWith(color: muted),
                  ),
              ],
            ),
          ),
        );

    final tiles = [
      if (weight != null)
        tile(
          Icons.monitor_weight_outlined,
          S.currentWeight,
          '${formatNumber(weight)} kg',
          weights.length >= 2
              ? S.weightChange(
                  weights.last.value - weights.first.value,
                  weights.first.date,
                )
              : null,
        ),
      if (bmi != null)
        tile(
          Icons.straighten,
          S.bmi,
          formatNumber(bmi),
          bmiRangeLabel(bmiRange(bmi)),
        ),
      if (bodyFat != null)
        tile(Icons.percent, S.bodyFat, '${formatNumber(bodyFat)}%', S.estimate),
    ];
    if (tiles.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(Gap.lg),
          child: Text(S.noWeightYet),
        ),
      );
    }

    // Lado a lado quando cabem; em telas estreitas ou com fonte ampliada,
    // um indicador por linha.
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final sideBySide = constraints.maxWidth >= 330 && scale <= 1.3;
        if (!sideBySide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, item) in tiles.indexed) ...[
                if (index > 0) const SizedBox(height: Gap.sm),
                item,
              ],
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, item) in tiles.indexed) ...[
                if (index > 0) const SizedBox(width: Gap.sm),
                Expanded(child: item),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric, required this.rows});

  final _Metric metric;
  final List<BodyMeasurementRow> rows;

  @override
  Widget build(BuildContext context) {
    final points = metric.points(rows);
    if (points.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Gap.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Gap.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(metric.label, style: context.text.titleMedium),
              const SizedBox(height: Gap.sm),
              // Uma medição sozinha não forma tendência: mostra o valor e
              // explica o que falta, em vez de desenhar uma linha.
              if (points.length < 2) ...[
                Text(
                  '${formatNumber(points.single.value)} ${metric.unit}',
                  style: context.text.headlineSmall,
                ),
                const SizedBox(height: Gap.xs),
                Text(
                  S.chartNeedsTwo,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ] else
                TrendChart(points: points, unit: metric.unit),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showMeasurementSheet(
  BuildContext context, {
  BodyMeasurementRow? existing,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  useRootNavigator: true,
  builder: (context) => _MeasurementSheet(existing: existing),
);

class _MeasurementSheet extends ConsumerStatefulWidget {
  const _MeasurementSheet({this.existing});

  final BodyMeasurementRow? existing;

  @override
  ConsumerState<_MeasurementSheet> createState() => _MeasurementSheetState();
}

class _MeasurementSheetState extends ConsumerState<_MeasurementSheet> {
  final _form = GlobalKey<FormState>();
  late LocalDate _date = widget.existing?.date ?? ref.read(todayProvider);
  late final _weight = _controller(widget.existing?.weightKg);
  late final _waist = _controller(widget.existing?.waistCm);
  late final _neck = _controller(widget.existing?.neckCm);
  late final _hip = _controller(widget.existing?.hipCm);
  bool _empty = false;

  TextEditingController _controller(double? value) =>
      TextEditingController(text: value == null ? '' : formatForInput(value));

  @override
  void dispose() {
    for (final controller in [_weight, _waist, _neck, _hip]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.toLocalNoon(),
      firstDate: DateTime(2000),
      lastDate: ref.read(todayProvider).toLocalNoon(),
    );
    if (picked != null) setState(() => _date = LocalDate.fromDateTime(picked));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final values = [
      _weight,
      _waist,
      _neck,
      _hip,
    ].map((controller) => parseDecimal(controller.text)).toList();
    if (values.every((value) => value == null)) {
      setState(() => _empty = true);
      return;
    }
    await ref
        .read(bodyRepositoryProvider)
        .save(
          id: widget.existing?.id,
          date: _date,
          weightKg: values[0],
          waistCm: values[1],
          neckCm: values[2],
          hipCm: values[3],
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final row = widget.existing!;
    final confirmed = await confirmAction(
      context,
      title: S.deleteMeasurementTitle,
      message: S.deleteMeasurementMessage(row.date),
      confirmLabel: S.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await ref.read(bodyRepositoryProvider).delete(row.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? S.editMeasurement : S.newMeasurement,
                style: context.text.titleLarge,
              ),
              const SizedBox(height: Gap.lg),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(Corner.md),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: S.date,
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(formatDate(_date)),
                ),
              ),
              const SizedBox(height: Gap.md),
              DecimalField(
                controller: _weight,
                label: S.weight,
                suffix: 'kg',
                min: 20,
                max: 400,
                onChanged: (_) => setState(() => _empty = false),
              ),
              const SizedBox(height: Gap.md),
              DecimalField(
                controller: _waist,
                label: S.waist,
                suffix: 'cm',
                allowZero: false,
                max: 300,
                onChanged: (_) => setState(() => _empty = false),
              ),
              const SizedBox(height: Gap.md),
              DecimalField(
                controller: _neck,
                label: S.neck,
                suffix: 'cm',
                allowZero: false,
                max: 100,
                onChanged: (_) => setState(() => _empty = false),
              ),
              const SizedBox(height: Gap.md),
              DecimalField(
                controller: _hip,
                label: S.hip,
                suffix: 'cm',
                allowZero: false,
                max: 300,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() => _empty = false),
              ),
              if (_empty) ...[
                const SizedBox(height: Gap.sm),
                Text(
                  S.measurementEmpty,
                  style: TextStyle(color: context.colors.error),
                ),
              ],
              const SizedBox(height: Gap.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text(S.save),
                ),
              ),
              if (isEditing) ...[
                const SizedBox(height: Gap.sm),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _delete,
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.error,
                    ),
                    child: const Text(S.deleteMeasurement),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
