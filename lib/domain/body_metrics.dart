import 'dart:math' as math;

import 'profile_enums.dart';

/// Índice de massa corporal: peso (kg) dividido pela altura (m) ao quadrado.
double? bodyMassIndex({required double weightKg, required double heightCm}) {
  if (weightKg <= 0 || heightCm <= 0) return null;
  final meters = heightCm / 100;
  return weightKg / (meters * meters);
}

/// Faixas de IMC para adultos segundo a OMS.
enum BmiRange { underweight, normal, overweight, obesity }

BmiRange bmiRange(double bmi) {
  if (bmi < 18.5) return BmiRange.underweight;
  if (bmi < 25) return BmiRange.normal;
  if (bmi < 30) return BmiRange.overweight;
  return BmiRange.obesity;
}

double _log10(double value) => math.log(value) / math.ln10;

/// Percentual de gordura corporal estimado pelo método da Marinha dos EUA
/// (Hodgdon e Beckett, 1984), com medidas em centímetros.
///
/// Homens usam cintura e pescoço; mulheres usam também o quadril. Devolve
/// null quando falta alguma medida ou quando as medidas não permitem a conta.
double? navyBodyFatPercent({
  required Sex sex,
  required double heightCm,
  double? waistCm,
  double? neckCm,
  double? hipCm,
}) {
  if (waistCm == null || neckCm == null || heightCm <= 0) return null;
  final double density;
  switch (sex) {
    case Sex.male:
      final girth = waistCm - neckCm;
      if (girth <= 0) return null;
      density = 1.0324 - 0.19077 * _log10(girth) + 0.15456 * _log10(heightCm);
    case Sex.female:
      if (hipCm == null) return null;
      final girth = waistCm + hipCm - neckCm;
      if (girth <= 0) return null;
      density = 1.29579 - 0.35004 * _log10(girth) + 0.22100 * _log10(heightCm);
  }
  final percent = 495 / density - 450;
  if (percent.isNaN || percent.isInfinite || percent < 0 || percent > 75) {
    return null;
  }
  return percent;
}
