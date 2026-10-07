import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/domain/body_metrics.dart';
import 'package:localdiet/domain/calorie_target.dart';
import 'package:localdiet/domain/intake_comparison.dart';
import 'package:localdiet/domain/local_date.dart';
import 'package:localdiet/domain/nutrients.dart';
import 'package:localdiet/domain/portion.dart';
import 'package:localdiet/domain/profile_enums.dart';
import 'package:localdiet/domain/taco_value.dart';

void main() {
  group('LocalDate', () {
    test('vai e volta como texto AAAA-MM-DD', () {
      const date = LocalDate(1990, 3, 7);
      expect(date.toIso(), '1990-03-07');
      expect(LocalDate.parse('1990-03-07'), date);
    });

    test('recusa datas que o calendário não tem e formatos estranhos', () {
      expect(LocalDate.tryParse('2026-02-30'), isNull);
      expect(LocalDate.tryParse('2026-13-01'), isNull);
      expect(LocalDate.tryParse('07/03/1990'), isNull);
      expect(LocalDate.tryParse('2026-2-3'), isNull);
      expect(() => LocalDate.parse('ontem'), throwsFormatException);
    });

    test('o dia vem do relógio local e não muda perto da meia-noite', () {
      // 23h30 locais continuam sendo o mesmo dia, em qualquer fuso.
      expect(
        LocalDate.fromDateTime(DateTime(2026, 10, 7, 23, 30)),
        const LocalDate(2026, 10, 7),
      );
      expect(
        LocalDate.fromDateTime(DateTime(2026, 10, 7, 0, 5)),
        const LocalDate(2026, 10, 7),
      );
    });

    test('soma dias atravessando mês, ano e ano bissexto', () {
      expect(
        const LocalDate(2026, 1, 31).addDays(1),
        const LocalDate(2026, 2, 1),
      );
      expect(
        const LocalDate(2026, 12, 31).addDays(1),
        const LocalDate(2027, 1, 1),
      );
      expect(
        const LocalDate(2028, 2, 28).addDays(1),
        const LocalDate(2028, 2, 29),
      );
      expect(
        const LocalDate(2026, 3, 1).addDays(-1),
        const LocalDate(2026, 2, 28),
      );
      expect(
        const LocalDate(
          2026,
          10,
          7,
        ).differenceInDays(const LocalDate(2026, 9, 30)),
        7,
      );
    });

    test('idade só aumenta no dia do aniversário', () {
      const birth = LocalDate(1990, 10, 8);
      expect(birth.ageOn(const LocalDate(2026, 10, 7)), 35);
      expect(birth.ageOn(const LocalDate(2026, 10, 8)), 36);
    });

    test('ordena e compara por valor', () {
      expect(
        const LocalDate(2026, 1, 2).isAfter(const LocalDate(2026, 1, 1)),
        isTrue,
      );
      expect(
        const LocalDate(2025, 12, 31).isBefore(const LocalDate(2026, 1, 1)),
        isTrue,
      );
      expect({
        LocalDate.parse('2026-01-01'),
        LocalDate.parse('2026-01-01'),
      }, hasLength(1));
    });
  });

  group('Nutrients', () {
    test('porção é valor por 100 g × gramas / 100', () {
      expect(Nutrients.portion(124, 252), closeTo(312.48, 1e-9));
      expect(Nutrients.portion(124, 100), 124);
      expect(Nutrients.portion(124, 0), 0);
    });

    test('forGrams aplica a mesma conta a todos os nutrientes', () {
      const per100 = Nutrients(
        kcal: 124,
        protein: 2.6,
        carb: 25.8,
        fat: 1.0,
        fiber: 2.7,
        sodium: 1,
      );
      final portion = per100.forGrams(50);
      expect(portion.kcal, closeTo(62, 1e-9));
      expect(portion.protein, closeTo(1.3, 1e-9));
      expect(portion.carb, closeTo(12.9, 1e-9));
      expect(portion.fat, closeTo(0.5, 1e-9));
      expect(portion.fiber, closeTo(1.35, 1e-9));
      expect(portion.sodium, closeTo(0.5, 1e-9));
    });

    test('soma itens e lista vazia dá zero', () {
      expect(Nutrients.sum(const []), Nutrients.zero);
      final total = Nutrients.sum(const [
        Nutrients(kcal: 100, protein: 5),
        Nutrients(kcal: 50, protein: 2, fat: 1),
      ]);
      expect(total, const Nutrients(kcal: 150, protein: 7, fat: 1));
    });
  });

  group('Portion', () {
    test('gramatura é quantidade × gramas da medida', () {
      const portion = Portion(
        measureLabel: 'unidade',
        measureGrams: 50,
        quantity: 2,
      );
      expect(portion.grams, 100);
      expect(const Portion.grams(252).grams, 252);
      expect(const Portion.grams(252).isInGrams, isTrue);
    });

    test('porção zerada, negativa ou não finita é inválida', () {
      expect(const Portion.grams(0).isValid, isFalse);
      expect(const Portion.grams(-5).isValid, isFalse);
      expect(const Portion.grams(double.nan).isValid, isFalse);
      expect(const Portion.grams(double.infinity).isValid, isFalse);
      expect(const Portion.grams(1).isValid, isTrue);
    });
  });

  group('TacoValue', () {
    test('distingue número, traço, não aplicável, reavaliação e ausente', () {
      expect(TacoValue.fromRaw(2.6), isA<TacoNumber>());
      expect(TacoValue.fromRaw(124), isA<TacoNumber>());
      expect(TacoValue.fromRaw('Tr'), isA<TacoTrace>());
      expect(TacoValue.fromRaw('NA'), isA<TacoNotApplicable>());
      expect(TacoValue.fromRaw('*'), isA<TacoUnderReview>());
      expect(TacoValue.fromRaw(null), isA<TacoMissing>());
      expect(() => TacoValue.fromRaw('?'), throwsFormatException);
    });

    test('só número e traço têm valor numérico', () {
      expect(TacoValue.fromRaw(2.6).numeric, 2.6);
      expect(TacoValue.fromRaw('Tr').numeric, 0);
      expect(TacoValue.fromRaw('NA').numeric, isNull);
      expect(TacoValue.fromRaw('*').numeric, isNull);
      expect(TacoValue.fromRaw(null).numeric, isNull);
    });
  });

  group('meta calórica', () {
    test('Mifflin-St Jeor para homem e mulher', () {
      expect(
        basalMetabolicRate(
          sex: Sex.male,
          weightKg: 80,
          heightCm: 180,
          ageYears: 30,
        ),
        1780,
      );
      expect(
        basalMetabolicRate(
          sex: Sex.female,
          weightKg: 60,
          heightCm: 165,
          ageYears: 30,
        ),
        1320.25,
      );
    });

    test(
      'gasto diário aplica o fator de atividade e o objetivo ajusta a meta',
      () {
        CalorieTarget target(Goal goal) => calorieTarget(
          sex: Sex.male,
          weightKg: 80,
          heightCm: 180,
          ageYears: 30,
          activity: ActivityLevel.moderate,
          goal: goal,
        );
        expect(target(Goal.maintain).dailyExpenditure, closeTo(2759, 1e-9));
        expect(target(Goal.maintain).value, closeTo(2759, 1e-9));
        expect(target(Goal.lose).value, closeTo(2207.2, 1e-9));
        expect(target(Goal.gain).value, closeTo(3034.9, 1e-9));
      },
    );

    test(
      'meta manual substitui a calculada e o aviso de basal a acompanha',
      () {
        final target = calorieTarget(
          sex: Sex.female,
          weightKg: 60,
          heightCm: 165,
          ageYears: 30,
          activity: ActivityLevel.sedentary,
          goal: Goal.lose,
          manualTarget: 1200,
        );
        expect(target.isManual, isTrue);
        expect(target.value, 1200);
        expect(target.calculated, closeTo(1320.25 * 1.2 * 0.8, 1e-9));
        expect(target.isBelowBmr, isTrue);
      },
    );

    test(
      'meta calculada para perder peso com atividade leve fica acima da basal',
      () {
        final target = calorieTarget(
          sex: Sex.female,
          weightKg: 60,
          heightCm: 165,
          ageYears: 30,
          activity: ActivityLevel.light,
          goal: Goal.lose,
        );
        expect(target.isBelowBmr, isFalse);
      },
    );
  });

  group('indicadores corporais', () {
    test('IMC e faixas da OMS', () {
      expect(bodyMassIndex(weightKg: 80, heightCm: 180), closeTo(24.69, 0.01));
      expect(bodyMassIndex(weightKg: 0, heightCm: 180), isNull);
      expect(bmiRange(18.4), BmiRange.underweight);
      expect(bmiRange(18.5), BmiRange.normal);
      expect(bmiRange(24.99), BmiRange.normal);
      expect(bmiRange(25), BmiRange.overweight);
      expect(bmiRange(30), BmiRange.obesity);
    });

    test('gordura corporal pelo método da Marinha', () {
      expect(
        navyBodyFatPercent(
          sex: Sex.male,
          heightCm: 180,
          waistCm: 90,
          neckCm: 40,
        ),
        closeTo(18.4, 0.2),
      );
      expect(
        navyBodyFatPercent(
          sex: Sex.female,
          heightCm: 165,
          waistCm: 75,
          neckCm: 33,
          hipCm: 100,
        ),
        closeTo(29.4, 0.2),
      );
    });

    test('sem as medidas necessárias não há estimativa', () {
      expect(
        navyBodyFatPercent(sex: Sex.male, heightCm: 180, waistCm: 90),
        isNull,
      );
      expect(
        navyBodyFatPercent(
          sex: Sex.female,
          heightCm: 165,
          waistCm: 75,
          neckCm: 33,
        ),
        isNull,
      );
      expect(
        navyBodyFatPercent(
          sex: Sex.male,
          heightCm: 180,
          waistCm: 38,
          neckCm: 40,
        ),
        isNull,
      );
    });
  });

  group('Real × Meta', () {
    test('abaixo da meta há restante e não há excedente', () {
      const status = IntakeStatus(consumed: 1500, target: 2000);
      expect(status.remaining, 500);
      expect(status.excess, 0);
      expect(status.isOver, isFalse);
      expect(status.progress, 0.75);
    });

    test('acima da meta mostra excedente, nunca restante negativo', () {
      const status = IntakeStatus(consumed: 2300, target: 2000);
      expect(status.remaining, 0);
      expect(status.excess, 300);
      expect(status.isOver, isTrue);
      expect(status.progress, 1);
    });

    test('sem meta não há restante, excedente nem progresso', () {
      const status = IntakeStatus(consumed: 80);
      expect(status.hasTarget, isFalse);
      expect(status.remaining, isNull);
      expect(status.excess, isNull);
      expect(status.progress, isNull);
    });

    test('calorias usam a meta do perfil e macros usam o Plano Base', () {
      const consumed = Nutrients(kcal: 1800, protein: 90, carb: 200, fat: 60);
      final withPlan = DayComparison.from(
        consumed: consumed,
        kcalTarget: 2200,
        plan: const Nutrients(kcal: 2500, protein: 120, carb: 250, fat: 70),
      );
      expect(withPlan.kcal.target, 2200);
      expect(withPlan.protein.target, 120);
      expect(withPlan.carb.target, 250);
      expect(withPlan.fat.target, 70);

      final withoutPlan = DayComparison.from(
        consumed: consumed,
        kcalTarget: 2200,
        plan: null,
      );
      expect(withoutPlan.kcal.target, 2200);
      expect(withoutPlan.protein.hasTarget, isFalse);
      expect(withoutPlan.carb.hasTarget, isFalse);
      expect(withoutPlan.fat.hasTarget, isFalse);
    });
  });
}
