import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/data/app_database.dart';
import 'package:localdiet/data/asset_importer.dart';
import 'package:localdiet/data/repositories/diary_repository.dart';
import 'package:localdiet/data/repositories/food_repository.dart';
import 'package:localdiet/data/repositories/plan_repository.dart';
import 'package:localdiet/data/repositories/profile_repository.dart';
import 'package:localdiet/domain/local_date.dart';
import 'package:localdiet/domain/nutrients.dart';
import 'package:localdiet/domain/portion.dart';
import 'package:localdiet/domain/profile_enums.dart';

import 'support.dart';

void main() {
  late AppDatabase db;
  late FoodRepository foods;
  late DiaryRepository diary;
  late PlanRepository plan;

  const today = LocalDate(2026, 10, 7);
  const yesterday = LocalDate(2026, 10, 6);

  setUp(() async {
    db = await databaseWithTaco();
    foods = FoodRepository(db);
    diary = DiaryRepository(db);
    plan = PlanRepository(db);
  });

  tearDown(() => db.close());

  Future<FoodRow> rice() async => (await foods.byId(riceId))!;
  Future<FoodRow> egg() async => (await foods.byId('taco:490'))!;

  group('Diário', () {
    test('registra a refeição e soma kcal e macros do dia', () async {
      await diary.addItems(today, MealType.lunch, [
        portionOf(await rice(), 252),
        portionOf(await egg(), 50),
      ]);
      final items = await diary.watchDay(today).first;
      expect(items.map((item) => item.foodName), [
        'Arroz, integral, cozido',
        'Ovo, de galinha, inteiro, frito',
      ]);
      expect(items.first.nutrients.kcal, closeTo(312.5, 0.05));
      final total = Nutrients.sum(items.map((item) => item.nutrients));
      expect(total.kcal, closeTo(312.48 + 120, 0.01));
      expect(total.protein, closeTo(2.6 * 2.52 + 15.6 * 0.5, 0.01));
    });

    test('cada dia e cada refeição têm seus itens', () async {
      await diary.addItems(today, MealType.breakfast, [
        portionOf(await egg(), 50),
      ]);
      await diary.addItems(today, MealType.lunch, [
        portionOf(await rice(), 100),
      ]);
      await diary.addItems(yesterday, MealType.lunch, [
        portionOf(await rice(), 80),
      ]);
      final items = await diary.watchDay(today).first;
      expect(items, hasLength(2));
      expect(items.map((item) => item.meal).toSet(), {
        MealType.breakfast,
        MealType.lunch,
      });
      expect(await diary.watchDay(yesterday).first, hasLength(1));
    });

    test('a data é gravada como texto AAAA-MM-DD', () async {
      await diary.addItems(today, MealType.dinner, [
        portionOf(await rice(), 100),
      ]);
      final raw = await db
          .customSelect('SELECT date FROM diary_items')
          .getSingle();
      expect(raw.read<String>('date'), '2026-10-07');
    });

    test('refeição com item inválido não salva nenhum item', () async {
      final items = [portionOf(await rice(), 150), portionOf(await egg(), 0)];
      await expectLater(
        diary.addItems(today, MealType.lunch, items),
        throwsArgumentError,
      );
      expect(await diary.watchDay(today).first, isEmpty);
    });

    test('o snapshot não muda quando o alimento é editado depois', () async {
      final id = await foods.saveUserFood(
        name: 'Granola da casa',
        per100: const Nutrients(kcal: 400, protein: 10, carb: 60, fat: 12),
      );
      await diary.addItems(today, MealType.breakfast, [
        portionOf((await foods.byId(id))!, 50),
      ]);
      await foods.saveUserFood(
        id: id,
        name: 'Granola nova receita',
        per100: const Nutrients(kcal: 300, protein: 8, carb: 50, fat: 6),
      );
      final item = (await diary.watchDay(today).first).single;
      expect(item.foodName, 'Granola da casa');
      expect(item.nutrients.kcal, 200);
      expect(item.nutrients.fat, 6);
    });

    test('o snapshot sobrevive a uma nova versão da TACO', () async {
      await diary.addItems(today, MealType.lunch, [
        portionOf(await rice(), 100),
      ]);
      await AssetImporter(db)
          .syncTaco(tacoLine(1, 'Arroz, integral, cozido', kcal: 999));
      expect((await rice()).kcal, 999);
      final item = (await diary.watchDay(today).first).single;
      expect(item.nutrients.kcal, 124);
    });

    test('editar a porção recalcula os valores a partir do snapshot', () async {
      await diary.addItems(today, MealType.lunch, [
        portionOf(await rice(), 100),
      ]);
      final id = (await diary.watchDay(today).first).single.id;
      await diary.updatePortion(
        id,
        const Portion(
          measureLabel: 'minha concha',
          measureGrams: 90,
          quantity: 2,
        ),
      );
      final item = (await diary.watchDay(today).first).single;
      expect(item.grams, 180);
      expect(item.measureLabel, 'minha concha');
      expect(item.nutrients.kcal, closeTo(223.2, 0.01));
      expect(
        () => diary.updatePortion(id, const Portion.grams(0)),
        throwsArgumentError,
      );
    });

    test('excluir e desfazer devolve o item idêntico', () async {
      await diary.addItems(today, MealType.lunch, [
        portionOf(await rice(), 100),
      ]);
      final item = (await diary.watchDay(today).first).single;
      await diary.deleteItem(item.id);
      expect(await diary.watchDay(today).first, isEmpty);
      await diary.restoreItem(item);
      expect((await diary.watchDay(today).first).single, item);
    });

    test('a última porção usada de um alimento fica disponível', () async {
      expect(await diary.lastForFood(riceId), isNull);
      await diary.addItems(yesterday, MealType.lunch, [
        portionOf(await rice(), 100),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await diary.addItems(today, MealType.lunch, [
        FoodPortion(
          foodId: riceId,
          foodName: 'Arroz, integral, cozido',
          per100: (await rice()).per100,
          portion: const Portion(
            measureLabel: 'colher de servir',
            measureGrams: 45,
            quantity: 3,
          ),
        ),
      ]);
      final last = (await diary.lastForFood(riceId))!;
      expect(last.measureLabel, 'colher de servir');
      expect(last.quantity, 3);
    });

    test('a última porção da mesma refeição tem preferência', () async {
      await diary.addItems(yesterday, MealType.breakfast, [
        portionOf(await rice(), 60),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await diary.addItems(today, MealType.lunch, [
        portionOf(await rice(), 200),
      ]);

      final first = await diary.lastForFood(riceId, meal: MealType.breakfast);
      expect(first!.grams, 60, reason: 'a do café, não a mais recente');
      expect((await diary.lastForFood(riceId))!.grams, 200);
      // Sem registro no jantar, vale o mais recente de qualquer refeição.
      final dinner = await diary.lastForFood(riceId, meal: MealType.dinner);
      expect(dinner!.grams, 200);
    });

    test('recentes e frequentes saem do Diário, por refeição', () async {
      await diary.addItems(yesterday, MealType.lunch, [
        portionOf(await rice(), 100),
        portionOf(await rice(), 50),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await diary.addItems(today, MealType.lunch, [
        portionOf(await egg(), 100),
      ]);

      final recents = await foods.watchRecents(MealType.lunch).first;
      expect(recents.map((food) => food.id), ['taco:490', riceId]);
      final frequents = await foods.watchFrequents(MealType.lunch).first;
      expect(frequents.map((food) => food.id), [riceId, 'taco:490']);
    });

    test('o histórico de uma refeição não aparece em outra', () async {
      await diary.addItems(yesterday, MealType.lunch, [
        portionOf(await rice(), 100),
      ]);
      await diary.addItems(today, MealType.breakfast, [
        portionOf(await egg(), 50),
      ]);

      final breakfast = await foods.watchRecents(MealType.breakfast).first;
      expect(breakfast.map((food) => food.id), ['taco:490']);
      final lunch = await foods.watchRecents(MealType.lunch).first;
      expect(lunch.map((food) => food.id), [riceId]);
      expect(await foods.watchRecents(MealType.dinner).first, isEmpty);

      final frequents = await foods.watchFrequents(MealType.breakfast).first;
      expect(frequents.map((food) => food.id), ['taco:490']);
      expect(await foods.watchFrequents(MealType.snack).first, isEmpty);
    });

    test(
      'alimento desativado some dos recentes mas fica no histórico',
      () async {
        final id = await foods.saveUserFood(
          name: 'Barra X',
          per100: sampleNutrients,
        );
        await diary.addItems(today, MealType.snack, [
          portionOf((await foods.byId(id))!, 30),
        ]);
        await foods.deactivateUserFood(id);
        expect(await foods.watchRecents(MealType.snack).first, isEmpty);
        expect((await diary.watchDay(today).first).single.foodName, 'Barra X');
      },
    );

    test('copiar refeição cria registros novos com snapshot atual', () async {
      final id = await foods.saveUserFood(
        name: 'Granola',
        per100: const Nutrients(kcal: 400),
      );
      await diary.addItems(yesterday, MealType.breakfast, [
        portionOf((await foods.byId(id))!, 50),
        portionOf(await egg(), 50),
      ]);
      await foods.saveUserFood(
        id: id,
        name: 'Granola',
        per100: const Nutrients(kcal: 300),
      );

      final copied = await diary.copyMeal(
        fromDate: yesterday,
        fromMeal: MealType.breakfast,
        toDate: today,
        toMeal: MealType.snack,
      );
      expect(copied, 2);

      final original = await diary.watchDay(yesterday).first;
      final copies = await diary.watchDay(today).first;
      expect(copies, hasLength(2));
      expect(copies.every((item) => item.meal == MealType.snack), isTrue);
      expect(
        copies
            .map((item) => item.id)
            .toSet()
            .intersection(original.map((item) => item.id).toSet()),
        isEmpty,
      );
      expect(original.first.nutrients.kcal, 200, reason: 'origem intacta');
      expect(copies.first.nutrients.kcal, 150, reason: 'valores atuais');
      expect(await diary.recentDaysWithItems(before: today), [yesterday]);
    });
  });

  group('Plano Base', () {
    test('soma por refeição e no dia usando os valores do alimento', () async {
      await plan.addItems(MealType.lunch, [
        portionOf(await rice(), 200),
        portionOf(await egg(), 100),
      ]);
      await plan.addItems(MealType.dinner, [portionOf(await rice(), 100)]);
      final entries = await plan.watchAll().first;
      expect(entries, hasLength(3));
      final total = Nutrients.sum(entries.map((entry) => entry.nutrients));
      expect(total.kcal, closeTo(124 * 3 + 240, 0.01));
      final lunch = Nutrients.sum(
        entries
            .where((entry) => entry.item.meal == MealType.lunch)
            .map((entry) => entry.nutrients),
      );
      expect(lunch.kcal, closeTo(124 * 2 + 240, 0.01));
    });

    test('acompanha mudanças no alimento, ao contrário do Diário', () async {
      final id = await foods.saveUserFood(
        name: 'Granola',
        per100: const Nutrients(kcal: 400),
      );
      await plan.addItems(MealType.breakfast, [
        portionOf((await foods.byId(id))!, 50),
      ]);
      await foods.saveUserFood(
        id: id,
        name: 'Granola',
        per100: const Nutrients(kcal: 300),
      );
      expect((await plan.watchAll().first).single.nutrients.kcal, 150);
    });

    test(
      'item de alimento desativado continua visível e pede revisão',
      () async {
        final id = await foods.saveUserFood(
          name: 'Barra X',
          per100: sampleNutrients,
        );
        await plan.addItems(MealType.snack, [
          portionOf((await foods.byId(id))!, 30),
        ]);
        await foods.deactivateUserFood(id);
        final entry = (await plan.watchAll().first).single;
        expect(entry.needsReview, isTrue);
        expect(entry.food.name, 'Barra X');
      },
    );

    test('editar porção, excluir e desfazer', () async {
      await plan.addItems(MealType.lunch, [portionOf(await rice(), 100)]);
      final entry = (await plan.watchAll().first).single;
      await plan.updatePortion(entry.item.id, const Portion.grams(250));
      expect((await plan.watchAll().first).single.nutrients.kcal, 310);
      await plan.deleteItem(entry.item.id);
      expect(await plan.watchAll().first, isEmpty);
      await plan.restoreItem(entry.item);
      expect((await plan.watchAll().first).single.item, entry.item);
    });

    test('plano com item inválido não salva nada', () async {
      await expectLater(
        plan.addItems(MealType.lunch, [
          portionOf(await rice(), 100),
          portionOf(await egg(), -1),
        ]),
        throwsArgumentError,
      );
      expect(await plan.watchAll().first, isEmpty);
    });
  });

  group('perfil e medições', () {
    late ProfileRepository profiles;
    late BodyRepository body;

    setUp(() {
      profiles = ProfileRepository(db);
      body = BodyRepository(db);
    });

    test('onboarding grava perfil e primeira medição juntos', () async {
      expect(await profiles.watch().first, isNull);
      await profiles.completeOnboarding(
        name: ' Gabriel ',
        birthDate: const LocalDate(1998, 10, 8),
        sex: Sex.male,
        heightCm: 178,
        goal: Goal.lose,
        activity: ActivityLevel.moderate,
        today: today,
        weightKg: 82.5,
        waistCm: 90,
      );
      final profile = (await profiles.watch().first)!;
      expect(profile.name, 'Gabriel');
      expect(profile.birthDate, const LocalDate(1998, 10, 8));
      expect(profile.birthDate.ageOn(today), 27);
      final measurement = (await body.watchAll().first).single;
      expect(measurement.date, today);
      expect(measurement.weightKg, 82.5);
      expect(measurement.neckCm, isNull);
    });

    test('a data de nascimento é texto e não muda de dia', () async {
      await profiles.save(
        name: 'Ana',
        birthDate: const LocalDate(1990, 1, 1),
        sex: Sex.female,
        heightCm: 165,
        goal: Goal.maintain,
        activity: ActivityLevel.light,
      );
      final raw = await db
          .customSelect('SELECT birth_date FROM profiles')
          .getSingle();
      expect(raw.read<String>('birth_date'), '1990-01-01');
    });

    test(
      'salvar de novo atualiza a única linha e guarda a meta manual',
      () async {
        Future<void> save(double? manual) => profiles.save(
          name: 'Ana',
          birthDate: const LocalDate(1990, 1, 1),
          sex: Sex.female,
          heightCm: 165,
          goal: Goal.maintain,
          activity: ActivityLevel.light,
          manualKcalTarget: manual,
        );
        await save(null);
        await save(1800);
        expect((await profiles.watch().first)!.manualKcalTarget, 1800);
        await save(null);
        expect((await profiles.watch().first)!.manualKcalTarget, isNull);
        final rows = await db
            .customSelect('SELECT COUNT(*) AS c FROM profiles')
            .getSingle();
        expect(rows.read<int>('c'), 1);
      },
    );

    test(
      'medições saem em ordem de data, com edição, exclusão e desfazer',
      () async {
        await body.save(date: today, weightKg: 82);
        await body.save(date: yesterday, weightKg: 82.6, waistCm: 91);
        var all = await body.watchAll().first;
        expect(all.map((row) => row.date), [yesterday, today]);

        await body.save(
          id: all.last.id,
          date: today,
          weightKg: 81.8,
          neckCm: 39,
        );
        all = await body.watchAll().first;
        expect(all.last.weightKg, 81.8);
        expect(all.last.neckCm, 39);

        final removed = all.first;
        await body.delete(removed.id);
        expect(await body.watchAll().first, hasLength(1));
        await body.restore(removed);
        expect((await body.watchAll().first).first, removed);
      },
    );

    test('medição vazia ou com valor inválido é recusada', () async {
      expect(() => body.save(date: today), throwsArgumentError);
      expect(() => body.save(date: today, weightKg: 0), throwsArgumentError);
      expect(() => body.save(date: today, waistCm: -3), throwsArgumentError);
    });

    test('preferências são gravadas por chave', () async {
      final settings = SettingsRepository(db);
      expect(await settings.watchValue('theme').first, isNull);
      await settings.setValue('theme', 'dark');
      await settings.setValue('theme', 'light');
      expect(await settings.watchValue('theme').first, 'light');
    });
  });
}
