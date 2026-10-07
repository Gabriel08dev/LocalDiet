import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/data/app_database.dart';
import 'package:localdiet/data/repositories/diary_repository.dart';
import 'package:localdiet/data/repositories/food_repository.dart';
import 'package:localdiet/data/repositories/plan_repository.dart';
import 'package:localdiet/data/tables.dart';
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

  setUp(() async {
    db = await databaseWithTaco();
    foods = FoodRepository(db);
    diary = DiaryRepository(db);
    plan = PlanRepository(db);

    final rice = (await foods.byId(riceId))!;
    final egg = (await foods.byId('taco:490'))!;
    await plan.addItems(MealType.lunch, [
      FoodPortion(
        foodId: rice.id,
        foodName: rice.name,
        per100: rice.per100,
        portion: const Portion(
          measureLabel: 'colher de servir',
          measureGrams: 63,
          quantity: 3,
        ),
      ),
      portionOf(egg, 100),
    ]);
    await plan.addItems(MealType.dinner, [portionOf(rice, 150)]);
  });

  tearDown(() => db.close());

  test('seguir o plano registra no Diário o que estava planejado', () async {
    final ids = await plan.followMeal(today, MealType.lunch);
    final items = await diary.watchDay(today).first;
    expect(items.map((item) => item.id), ids);
    expect(items.every((item) => item.meal == MealType.lunch), isTrue);

    final rice = items.first;
    expect(rice.foodName, 'Arroz, integral, cozido');
    expect(rice.measureLabel, 'colher de servir');
    expect(rice.quantity, 3);
    expect(rice.grams, 189);

    final total = Nutrients.sum(items.map((item) => item.nutrients));
    final planned = Nutrients.sum(
      (await plan.watchAll().first)
          .where((entry) => entry.item.meal == MealType.lunch)
          .map((entry) => entry.nutrients),
    );
    expect(total.kcal, closeTo(planned.kcal, 1e-9));
    expect(await plan.watchChecks(today).first, {
      MealType.lunch: PlanCheckStatus.followed,
    });
  });

  test(
    'seguir de novo uma refeição já seguida não registra em dobro',
    () async {
      final first = await plan.followMeal(today, MealType.lunch);
      final second = await plan.followMeal(today, MealType.lunch);
      expect(first, hasLength(2));
      expect(second, isEmpty);
      expect(await diary.watchDay(today).first, hasLength(2));
    },
  );

  test(
    'refeição marcada como outra ainda pode seguir o plano depois',
    () async {
      await plan.markOther(today, MealType.lunch);
      expect(await plan.followMeal(today, MealType.lunch), hasLength(2));
    },
  );

  test('o que foi registrado ao seguir o plano é um snapshot', () async {
    final id = await foods.saveUserFood(
      name: 'Granola',
      per100: const Nutrients(kcal: 400),
    );
    await plan.addItems(MealType.breakfast, [
      portionOf((await foods.byId(id))!, 50),
    ]);
    await plan.followMeal(today, MealType.breakfast);
    await foods.saveUserFood(
      id: id,
      name: 'Granola',
      per100: const Nutrients(kcal: 300),
    );
    final item = (await diary.watchDay(today).first).single;
    expect(item.nutrients.kcal, 200);
  });

  test('desfazer tira do Diário só o que o plano registrou', () async {
    await diary.addItems(today, MealType.lunch, [
      portionOf((await foods.byId(riceId))!, 30),
    ]);
    final ids = await plan.followMeal(today, MealType.lunch);
    expect(await diary.watchDay(today).first, hasLength(3));

    await plan.undoFollow(today, MealType.lunch, ids);
    final items = await diary.watchDay(today).first;
    expect(items.single.grams, 30);
    expect(await plan.watchChecks(today).first, isEmpty);
  });

  test('refeição sem itens no plano não pode ser seguida', () async {
    await expectLater(
      plan.followMeal(today, MealType.breakfast),
      throwsStateError,
    );
    expect(await diary.watchDay(today).first, isEmpty);
    expect(await plan.watchChecks(today).first, isEmpty);
  });

  test('marcar outra refeição não registra nada no Diário', () async {
    await plan.markOther(today, MealType.lunch);
    expect(await diary.watchDay(today).first, isEmpty);
    expect(await plan.watchChecks(today).first, {
      MealType.lunch: PlanCheckStatus.other,
    });
  });

  test('a marcação é uma por refeição e por dia, e pode ser trocada', () async {
    await plan.markOther(today, MealType.lunch);
    await plan.followMeal(today, MealType.lunch);
    await plan.markOther(today, MealType.dinner);
    await plan.markOther(today.addDays(-1), MealType.lunch);

    expect(await plan.watchChecks(today).first, {
      MealType.lunch: PlanCheckStatus.followed,
      MealType.dinner: PlanCheckStatus.other,
    });
    expect(await plan.watchChecks(today.addDays(-1)).first, {
      MealType.lunch: PlanCheckStatus.other,
    });
    final rows = await db
        .customSelect('SELECT COUNT(*) AS c FROM plan_checks')
        .getSingle();
    expect(rows.read<int>('c'), 3);
  });

  test('desmarcar mantém o que já está no Diário', () async {
    await plan.followMeal(today, MealType.dinner);
    await plan.clearCheck(today, MealType.dinner);
    expect(await plan.watchChecks(today).first, isEmpty);
    expect(await diary.watchDay(today).first, hasLength(1));
  });

  test('a data da marcação é texto AAAA-MM-DD', () async {
    await plan.markOther(today, MealType.lunch);
    final raw = await db
        .customSelect('SELECT date FROM plan_checks')
        .getSingle();
    expect(raw.read<String>('date'), '2026-10-07');
  });

  test('adesão conta seguidas e trocadas só dentro do período', () async {
    await plan.followMeal(today, MealType.lunch);
    await plan.followMeal(today, MealType.dinner);
    await plan.markOther(today.addDays(-1), MealType.lunch);
    await plan.followMeal(today.addDays(-6), MealType.lunch);
    await plan.followMeal(today.addDays(-7), MealType.lunch);
    await plan.markOther(today.addDays(1), MealType.lunch);

    final week = await plan
        .watchAdherence(from: today.addDays(-6), to: today)
        .first;
    expect(week.followed, 3);
    expect(week.other, 1);
    expect(week.marked, 4);
    expect(week.rate, 0.75);
  });

  test('sem marcações não há taxa de adesão', () async {
    final week = await plan
        .watchAdherence(from: today.addDays(-6), to: today)
        .first;
    expect(week.marked, 0);
    expect(week.rate, isNull);
  });
}
