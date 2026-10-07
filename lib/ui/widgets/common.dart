import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/intake_comparison.dart';
import '../../domain/nutrients.dart';
import '../../domain/profile_enums.dart';
import '../format.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import 'motion.dart';

/// O ícone de cada refeição, usado em todo o app para reconhecê-la de relance.
IconData mealIcon(MealType meal) => switch (meal) {
  MealType.breakfast => Icons.free_breakfast_outlined,
  MealType.lunch => Icons.restaurant_outlined,
  MealType.snack => Icons.cookie_outlined,
  MealType.dinner => Icons.dinner_dining_outlined,
  MealType.other => Icons.local_dining_outlined,
};

/// O tom pastel de cada refeição.
Tone mealTone(BuildContext context, MealType meal) {
  final colors = context.appColors;
  return switch (meal) {
    MealType.breakfast => colors.peach,
    MealType.lunch => colors.mint,
    MealType.snack => colors.pink,
    MealType.dinner => colors.lavender,
    MealType.other => colors.sky,
  };
}

/// Ícone dentro de um quadrado bem arredondado, em um tom pastel.
///
/// Sem [tone], usa o cinza neutro do tema.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.tone, this.size = 44});

  final IconData icon;
  final Tone? tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: Motion.of(context, Motion.base),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone?.background ?? colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(size * 0.36),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: tone?.foreground ?? colors.onSurfaceVariant,
      ),
    );
  }
}

/// A marca do app: um anel de progresso com um ponto no centro.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.hero,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: CustomPaint(painter: _BrandPainter(colors.onHero)),
    );
  }
}

class _BrandPainter extends CustomPainter {
  _BrandPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.24;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.085
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, size.width * 0.07, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BrandPainter old) => old.color != color;
}

/// Estado vazio com ícone, explicação e, quando existe, uma ação real.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Gap.xl,
        vertical: Gap.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconBadge(icon, size: 56),
          const SizedBox(height: Gap.lg),
          Text(
            title,
            style: context.text.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: Gap.xs),
            Text(
              message!,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[const SizedBox(height: Gap.lg), action!],
        ],
      ),
    );
  }
}

/// Título de seção com um espaço opcional para ação à direita.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.xs, Gap.xl, Gap.xs, Gap.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Campo numérico que aceita vírgula ou ponto decimal.
class DecimalField extends StatelessWidget {
  const DecimalField({
    super.key,
    required this.controller,
    required this.label,
    this.suffix,
    this.required = false,
    this.allowZero = true,
    this.min,
    this.max,
    this.helper,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final String? suffix;
  final bool required;
  final bool allowZero;
  final double? min;
  final double? max;
  final String? helper;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;

  String? _validate(String? text) {
    final trimmed = (text ?? '').trim();
    if (trimmed.isEmpty) return required ? S.requiredField : null;
    final value = parseDecimal(trimmed);
    if (value == null) return S.invalidNumber;
    if (!allowZero && value == 0) return S.mustBePositive;
    if (min != null && value < min!) return S.minValue(min!);
    if (max != null && value > max!) return S.maxValue(max!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        helperText: helper,
        helperMaxLines: 3,
      ),
      validator: _validate,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(S.cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: context.colors.error,
                  foregroundColor: context.colors.onError,
                  minimumSize: const Size(64, 44),
                )
              : FilledButton.styleFrom(minimumSize: const Size(64, 44)),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Avisa de uma exclusão e oferece desfazer.
void showUndo(BuildContext context, String message, VoidCallback onUndo) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: S.undo, onPressed: onUndo),
        persist: false,
        duration: const Duration(seconds: 6),
      ),
    );
}

/// "P 12 g · C 30 g · G 5 g", para linhas compactas.
class MacroLine extends StatelessWidget {
  const MacroLine(this.nutrients, {super.key});

  final Nutrients nutrients;

  @override
  Widget build(BuildContext context) {
    final style = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    return Text(S.macroLine(nutrients), style: style);
  }
}

/// Barra fina de progresso com pontas arredondadas.
class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.value,
    required this.color,
    this.height = 6,
    this.track,
  });

  /// Fração entre 0 e 1, ou null para uma barra de espera sem fim.
  final double? value;
  final Color color;
  final double height;
  final Color? track;

  @override
  Widget build(BuildContext context) {
    Widget bar(double? fraction) => ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: height,
        color: color,
        backgroundColor: track ?? context.colors.surfaceContainerHighest,
      ),
    );
    final target = value;
    if (target == null) return bar(null);
    return AnimatedFraction(
      value: target,
      builder: (context, fraction) => bar(fraction),
    );
  }
}

/// Um macronutriente: quanto foi consumido e, quando há meta, a fração dela.
///
/// A cor identifica o nutriente em um marcador e na barra; os números usam
/// as cores de texto do tema.
class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.label,
    required this.status,
    required this.color,
  });

  final String label;
  final IntakeStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
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
        const SizedBox(height: Gap.xs),
        Text(
          status.hasTarget
              ? S.gramsOfTarget(status.consumed, status.target!)
              : formatGrams(status.consumed),
          style: context.text.titleSmall,
        ),
        const SizedBox(height: Gap.sm),
        ProgressLine(value: status.progress ?? 0, color: color),
      ],
    );
  }
}

/// Proteína, carboidrato e gordura do dia, lado a lado.
class MacroBars extends StatelessWidget {
  const MacroBars(this.comparison, {super.key});

  final DayComparison comparison;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MacroTile(
            label: S.protein,
            status: comparison.protein,
            color: colors.protein,
          ),
        ),
        const SizedBox(width: Gap.lg),
        Expanded(
          child: _MacroTile(
            label: S.carb,
            status: comparison.carb,
            color: colors.carb,
          ),
        ),
        const SizedBox(width: Gap.lg),
        Expanded(
          child: _MacroTile(
            label: S.fat,
            status: comparison.fat,
            color: colors.fat,
          ),
        ),
      ],
    );
  }
}

/// Frase que resume calorias do dia frente à meta: restante, excedente ou,
/// sem meta, nada.
///
/// Com [onHero], usa as cores do cartão de destaque do Início.
class KcalStatusText extends StatelessWidget {
  const KcalStatusText(
    this.status, {
    super.key,
    this.style,
    this.onHero = false,
  });

  final IntakeStatus status;
  final TextStyle? style;
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final base = style ?? const TextStyle();
    if (!status.hasTarget) return Text(S.noKcalTarget, style: base);
    if (status.isOver) {
      return Text(
        S.kcalOver(status.excess!),
        style: base.copyWith(
          color: onHero ? context.appColors.heroOver : context.appColors.over,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    return Text(S.kcalRemaining(status.remaining!), style: base);
  }
}

/// Anel com as calorias consumidas no centro.
///
/// Com [onHero], usa as cores do cartão de destaque do Início.
class KcalRing extends StatelessWidget {
  const KcalRing(
    this.status, {
    super.key,
    this.size = 132,
    this.onHero = false,
  });

  final IntakeStatus status;
  final double size;
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final app = context.appColors;
    final colors = context.colors;
    final ink = onHero ? app.onHero : colors.onSurface;
    final progress = status.isOver
        ? (onHero ? app.heroOver : app.over)
        : (onHero ? app.onHero : colors.primary);
    final track = onHero
        ? app.onHero.withValues(alpha: 0.12)
        : colors.surfaceContainerHighest;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedFraction(
            value: status.progress ?? 0,
            builder: (context, fraction) => CircularProgressIndicator(
              value: fraction,
              strokeWidth: size * 0.095,
              strokeCap: StrokeCap.round,
              color: progress,
              backgroundColor: track,
            ),
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.all(size * 0.16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedCount(
                      status.consumed,
                      format: formatInteger,
                      style: context.text.headlineMedium?.copyWith(color: ink),
                    ),
                    Text(
                      S.kcalUnit,
                      style: context.text.labelMedium?.copyWith(
                        color: ink.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Uma linha de alimento dentro de uma refeição.
class MealLine {
  const MealLine({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kcal,
    required this.onTap,
    required this.onDelete,
    this.warning,
  });

  final String id;
  final String title;
  final String subtitle;
  final double kcal;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  /// Aviso exibido no lugar do subtítulo, quando o item pede atenção.
  final String? warning;
}

/// Bloco de uma refeição: ícone, nome, total, botão de adicionar e os itens.
class MealBlock extends StatelessWidget {
  const MealBlock({
    super.key,
    required this.title,
    required this.icon,
    required this.lines,
    required this.onAdd,
    this.tone,
    this.menu,
    this.status,
    this.emptyText = S.nothingLogged,
  });

  final String title;
  final IconData icon;
  final Tone? tone;

  /// O que aparece sob o nome quando a refeição não tem itens.
  final String emptyText;
  final List<MealLine> lines;
  final VoidCallback onAdd;
  final Widget? menu;

  /// Situação da refeição frente ao Plano Base, quando foi marcada.
  final String? status;

  @override
  Widget build(BuildContext context) {
    final total = lines.fold<double>(0, (sum, line) => sum + line.kcal);
    final muted = context.colors.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: Gap.md),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.lg,
                Gap.md,
                Gap.xs,
                Gap.md,
              ),
              child: Row(
                children: [
                  IconBadge(icon, tone: tone),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.text.titleMedium),
                        Text(
                          lines.isEmpty && status == null
                              ? emptyText
                              : [
                                  ?status,
                                  if (lines.isNotEmpty) formatKcal(total),
                                ].join(' · '),
                          style: context.text.bodySmall?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                  ?menu,
                  IconButton(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_circle),
                    color: context.colors.primary,
                    tooltip: S.addToMeal(title),
                  ),
                ],
              ),
            ),
            if (lines.isNotEmpty)
              const Divider(indent: Gap.lg, endIndent: Gap.lg),
            for (final line in lines)
              Dismissible(
                key: ValueKey(line.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: context.colors.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: Gap.xl),
                  child: Icon(
                    Icons.delete_outline,
                    color: context.colors.onErrorContainer,
                  ),
                ),
                onDismissed: (_) => line.onDelete(),
                child: ListTile(
                  title: Text(line.title),
                  subtitle: line.warning == null
                      ? Text(line.subtitle)
                      : Text(
                          line.warning!,
                          style: TextStyle(color: context.colors.error),
                        ),
                  trailing: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: formatInteger(line.kcal),
                          style: context.text.titleMedium,
                        ),
                        TextSpan(
                          text: ' ${S.kcalUnit}',
                          style: context.text.labelSmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: line.onTap,
                ),
              ),
            if (lines.isNotEmpty) const SizedBox(height: Gap.xs),
          ],
        ),
      ),
    );
  }
}

/// Aviso discreto em faixa, para informações que o usuário precisa ver.
class InfoBanner extends StatelessWidget {
  const InfoBanner(this.message, {super.key, this.icon = Icons.info_outline});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: context.colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(Corner.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.colors.onTertiaryContainer),
          const SizedBox(width: Gap.sm),
          Expanded(
            child: Text(
              message,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
