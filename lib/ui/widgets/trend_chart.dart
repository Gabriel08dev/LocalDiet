import 'package:flutter/material.dart';

import '../../domain/local_date.dart';
import '../format.dart';
import '../theme/app_theme.dart';

class TrendPoint {
  const TrendPoint(this.date, this.value);

  final LocalDate date;
  final double value;
}

/// Gráfico de linha de uma única medida ao longo do tempo.
///
/// O eixo horizontal é proporcional aos dias, não à ordem das medições. O
/// valor em destaque acima do gráfico é o mais recente, ou o ponto tocado.
/// Só deve ser usado com dois pontos ou mais: com um ponto não há tendência
/// a mostrar.
class TrendChart extends StatefulWidget {
  const TrendChart({super.key, required this.points, required this.unit})
    : assert(points.length >= 2);

  final List<TrendPoint> points;
  final String unit;

  @override
  State<TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<TrendChart> {
  int? _selected;

  static const _height = 168.0;

  void _selectAt(Offset position, double width) {
    final geometry = _Geometry(widget.points, Size(width, _height));
    var nearest = 0;
    var best = double.infinity;
    for (var index = 0; index < widget.points.length; index++) {
      final distance = (geometry.offsetOf(index).dx - position.dx).abs();
      if (distance < best) {
        best = distance;
        nearest = index;
      }
    }
    setState(() => _selected = nearest);
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    final shown = points[_selected ?? points.length - 1];
    final scaler = MediaQuery.textScalerOf(context);
    final labelStyle = context.text.labelSmall!.copyWith(
      color: context.colors.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Gap.sm,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              '${formatNumber(shown.value)} ${widget.unit}',
              style: context.text.headlineSmall,
            ),
            Text(formatDate(shown.date), style: context.text.bodyMedium),
          ],
        ),
        const SizedBox(height: Gap.md),
        LayoutBuilder(
          builder: (context, constraints) => Semantics(
            label:
                '${formatNumber(points.first.value)} ${widget.unit} em '
                '${formatDate(points.first.date)}, '
                '${formatNumber(points.last.value)} ${widget.unit} em '
                '${formatDate(points.last.date)}',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  _selectAt(details.localPosition, constraints.maxWidth),
              onHorizontalDragUpdate: (details) =>
                  _selectAt(details.localPosition, constraints.maxWidth),
              child: CustomPaint(
                size: Size(constraints.maxWidth, _height),
                painter: _TrendPainter(
                  points: points,
                  selected: _selected,
                  line: context.colors.primary,
                  surface: context.colors.surfaceContainerLow,
                  grid: context.colors.outlineVariant,
                  labelStyle: labelStyle,
                  scaler: scaler,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Converte medições em posições dentro da área do gráfico.
class _Geometry {
  _Geometry(this.points, this.size) {
    final values = points.map((point) => point.value);
    var low = values.reduce((a, b) => a < b ? a : b);
    var high = values.reduce((a, b) => a > b ? a : b);
    if (high == low) {
      low -= 1;
      high += 1;
    }
    final margin = (high - low) * 0.12;
    min = low - margin;
    max = high + margin;
    dataMin = low;
    dataMax = high;
    days = points.last.date.differenceInDays(points.first.date);
  }

  static const left = 44.0;
  static const right = 12.0;
  static const top = 8.0;
  static const bottom = 24.0;

  final List<TrendPoint> points;
  final Size size;
  late final double min;
  late final double max;
  late final double dataMin;
  late final double dataMax;
  late final int days;

  double get plotWidth => size.width - left - right;
  double get plotHeight => size.height - top - bottom;

  double yOf(double value) =>
      top + plotHeight * (1 - (value - min) / (max - min));

  Offset offsetOf(int index) {
    final point = points[index];
    final fraction = days == 0
        ? index / (points.length - 1)
        : point.date.differenceInDays(points.first.date) / days;
    return Offset(left + plotWidth * fraction, yOf(point.value));
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.selected,
    required this.line,
    required this.surface,
    required this.grid,
    required this.labelStyle,
    required this.scaler,
  });

  final List<TrendPoint> points;
  final int? selected;
  final Color line;
  final Color surface;
  final Color grid;
  final TextStyle labelStyle;
  final TextScaler scaler;

  TextPainter _label(String text) => TextPainter(
    text: TextSpan(text: text, style: labelStyle),
    textDirection: TextDirection.ltr,
    textScaler: scaler,
    maxLines: 1,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = _Geometry(points, size);
    final gridPaint = Paint()
      ..color = grid.withValues(alpha: 0.6)
      ..strokeWidth = 1;

    // Linhas de referência discretas no menor e no maior valor medidos.
    for (final value in {geometry.dataMin, geometry.dataMax}) {
      final y = geometry.yOf(value);
      canvas.drawLine(
        Offset(_Geometry.left, y),
        Offset(size.width - _Geometry.right, y),
        gridPaint,
      );
      final label = _label(formatNumber(value));
      label.paint(
        canvas,
        Offset(_Geometry.left - label.width - 6, y - label.height / 2),
      );
    }

    final first = _label(formatDayMonth(points.first.date));
    final last = _label(formatDayMonth(points.last.date));
    final labelsY = size.height - _Geometry.bottom + 6;
    first.paint(canvas, Offset(_Geometry.left, labelsY));
    last.paint(
      canvas,
      Offset(size.width - _Geometry.right - last.width, labelsY),
    );

    final offsets = [
      for (var index = 0; index < points.length; index++)
        geometry.offsetOf(index),
    ];

    if (selected != null) {
      final x = offsets[selected!].dx;
      canvas.drawLine(
        Offset(x, _Geometry.top),
        Offset(x, size.height - _Geometry.bottom),
        gridPaint,
      );
    }

    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Com muitos pontos, marcar todos esconderia a linha: ficam só o último e
    // o selecionado.
    final sparse = points.length > 24;
    for (var index = 0; index < offsets.length; index++) {
      final isSelected = index == selected;
      final isLast = index == offsets.length - 1;
      if (sparse && !isSelected && !isLast) continue;
      final radius = isSelected ? 6.0 : 4.0;
      canvas.drawCircle(offsets[index], radius + 2, Paint()..color = surface);
      canvas.drawCircle(offsets[index], radius, Paint()..color = line);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.points != points ||
      old.selected != selected ||
      old.line != line ||
      old.surface != surface ||
      old.scaler != scaler;
}
