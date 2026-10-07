import 'nutrients.dart';

/// Comparação de um valor consumido com sua meta.
///
/// Sem meta, não há restante nem excedente: o app mostra só o consumido.
/// Acima da meta, a diferença aparece como [excess], nunca como restante
/// negativo.
class IntakeStatus {
  const IntakeStatus({required this.consumed, this.target});

  final double consumed;
  final double? target;

  bool get hasTarget => target != null && target! > 0;

  double? get remaining {
    if (!hasTarget) return null;
    final difference = target! - consumed;
    return difference > 0 ? difference : 0;
  }

  double? get excess {
    if (!hasTarget) return null;
    final difference = consumed - target!;
    return difference > 0 ? difference : 0;
  }

  bool get isOver => (excess ?? 0) > 0;

  /// Fração da meta já consumida, limitada a 1 para barras de progresso.
  double? get progress {
    if (!hasTarget) return null;
    final fraction = consumed / target!;
    return fraction > 1 ? 1 : fraction;
  }
}

/// Real × Meta de um dia.
///
/// As calorias são comparadas à meta calórica do perfil. Os macronutrientes
/// são comparados ao Plano Base; sem plano, ficam sem meta.
class DayComparison {
  const DayComparison({
    required this.kcal,
    required this.protein,
    required this.carb,
    required this.fat,
  });

  factory DayComparison.from({
    required Nutrients consumed,
    required double? kcalTarget,
    required Nutrients? plan,
  }) => DayComparison(
    kcal: IntakeStatus(consumed: consumed.kcal, target: kcalTarget),
    protein: IntakeStatus(consumed: consumed.protein, target: plan?.protein),
    carb: IntakeStatus(consumed: consumed.carb, target: plan?.carb),
    fat: IntakeStatus(consumed: consumed.fat, target: plan?.fat),
  );

  final IntakeStatus kcal;
  final IntakeStatus protein;
  final IntakeStatus carb;
  final IntakeStatus fat;
}
