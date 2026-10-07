import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/intake_comparison.dart';
import '../../domain/nutrients.dart';
import '../format.dart';
import '../strings.dart';
import '../theme/app_theme.dart';

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
          Icon(icon, size: 40, color: context.colors.onSurfaceVariant),
          const SizedBox(height: Gap.md),
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
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xl, Gap.sm, Gap.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.text.titleMedium)),
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

/// Barra de um macronutriente: consumido e, quando há meta, a fração dela.
class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.status,
    required this.color,
  });

  final String label;
  final IntakeStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final value = status.hasTarget
        ? S.gramsOfTarget(status.consumed, status.target!)
        : formatGrams(status.consumed);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.labelMedium),
        const SizedBox(height: Gap.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: status.progress ?? 0,
            minHeight: 6,
            color: color,
            backgroundColor: context.colors.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: Gap.xs),
        Text(
          value,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
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
          child: _MacroBar(
            label: S.protein,
            status: comparison.protein,
            color: colors.protein,
          ),
        ),
        const SizedBox(width: Gap.md),
        Expanded(
          child: _MacroBar(
            label: S.carb,
            status: comparison.carb,
            color: colors.carb,
          ),
        ),
        const SizedBox(width: Gap.md),
        Expanded(
          child: _MacroBar(
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
class KcalStatusText extends StatelessWidget {
  const KcalStatusText(this.status, {super.key, this.style});

  final IntakeStatus status;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (!status.hasTarget) {
      return Text(S.noKcalTarget, style: style);
    }
    if (status.isOver) {
      return Text(
        S.kcalOver(status.excess!),
        style: (style ?? const TextStyle()).copyWith(
          color: context.appColors.over,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return Text(S.kcalRemaining(status.remaining!), style: style);
  }
}

/// Anel com as calorias consumidas no centro.
class KcalRing extends StatelessWidget {
  const KcalRing(this.status, {super.key, this.size = 132});

  final IntakeStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = status.isOver
        ? context.appColors.over
        : context.colors.primary;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: status.progress ?? 0,
            strokeWidth: 10,
            strokeCap: StrokeCap.round,
            color: color,
            backgroundColor: context.colors.surfaceContainerHighest,
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(Gap.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatInteger(status.consumed),
                      style: context.text.headlineMedium,
                    ),
                    Text(
                      S.kcalUnit,
                      style: context.text.labelMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
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

/// Bloco de uma refeição: nome, total, botão de adicionar e os itens.
class MealBlock extends StatelessWidget {
  const MealBlock({
    super.key,
    required this.title,
    required this.lines,
    required this.onAdd,
    this.menu,
    this.status,
  });

  final String title;
  final List<MealLine> lines;
  final VoidCallback onAdd;
  final Widget? menu;

  /// Situação da refeição frente ao Plano Base, quando foi marcada.
  final String? status;

  @override
  Widget build(BuildContext context) {
    final total = lines.fold<double>(0, (sum, line) => sum + line.kcal);
    return Padding(
      padding: const EdgeInsets.only(top: Gap.md),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.lg,
                Gap.sm,
                Gap.xs,
                Gap.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.text.titleMedium),
                        if (lines.isNotEmpty || status != null)
                          Text(
                            [
                              ?status,
                              if (lines.isNotEmpty) formatKcal(total),
                            ].join(' · '),
                            style: context.text.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ?menu,
                  IconButton(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: S.addToMeal(title),
                  ),
                ],
              ),
            ),
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
                  trailing: Text(
                    formatInteger(line.kcal),
                    style: context.text.titleMedium,
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
