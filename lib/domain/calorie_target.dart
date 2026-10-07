import 'profile_enums.dart';

/// Ajuste percentual sobre o gasto diário conforme o objetivo.
///
/// É uma convenção do app, não um valor de referência clínico. Quem tem uma
/// meta definida por profissional usa a meta manual.
const goalAdjustment = {Goal.lose: -0.20, Goal.maintain: 0.0, Goal.gain: 0.10};

/// Taxa metabólica basal pela equação de Mifflin-St Jeor (1990), em kcal/dia.
double basalMetabolicRate({
  required Sex sex,
  required double weightKg,
  required double heightCm,
  required int ageYears,
}) {
  final base = 10 * weightKg + 6.25 * heightCm - 5 * ageYears;
  return switch (sex) {
    Sex.male => base + 5,
    Sex.female => base - 161,
  };
}

class CalorieTarget {
  const CalorieTarget({
    required this.bmr,
    required this.dailyExpenditure,
    required this.calculated,
    this.manual,
  });

  /// Taxa metabólica basal estimada.
  final double bmr;

  /// Gasto diário estimado: basal × fator de atividade.
  final double dailyExpenditure;

  /// Meta calculada a partir do gasto diário e do objetivo.
  final double calculated;

  /// Meta definida pelo usuário, quando existe.
  final double? manual;

  /// A meta em vigor.
  double get value => manual ?? calculated;

  bool get isManual => manual != null;

  /// Verdadeiro quando a meta em vigor fica abaixo da taxa basal estimada.
  /// O app avisa, mas não altera a meta.
  bool get isBelowBmr => value < bmr;
}

CalorieTarget calorieTarget({
  required Sex sex,
  required double weightKg,
  required double heightCm,
  required int ageYears,
  required ActivityLevel activity,
  required Goal goal,
  double? manualTarget,
}) {
  final bmr = basalMetabolicRate(
    sex: sex,
    weightKg: weightKg,
    heightCm: heightCm,
    ageYears: ageYears,
  );
  final expenditure = bmr * activity.factor;
  return CalorieTarget(
    bmr: bmr,
    dailyExpenditure: expenditure,
    calculated: expenditure * (1 + goalAdjustment[goal]!),
    manual: manualTarget,
  );
}
