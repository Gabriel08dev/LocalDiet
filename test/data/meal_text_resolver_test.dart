import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/data/app_database.dart';
import 'package:localdiet/data/meal_text_resolver.dart';
import 'package:localdiet/data/repositories/food_repository.dart';
import 'package:localdiet/data/repositories/measure_repository.dart';

import 'support.dart';

void main() {
  late AppDatabase db;
  late MealTextResolver resolver;

  setUp(() async {
    db = await databaseWithTaco();
    resolver = MealTextResolver(FoodRepository(db), MeasureRepository(db));
  });

  tearDown(() => db.close());

  test(
    'gramas do texto viram a porção e o alimento pronto é o proposto',
    () async {
      final item = (await resolver.resolve('150 g de arroz integral')).single;
      expect(item.food!.name, 'Arroz, integral, cozido');
      expect(item.grams, 150);
      expect(item.candidates.length, greaterThan(1));
      expect(item.oilGrams, isNull);
    },
  );

  test('preparo que não está no nome do alimento sugere óleo', () async {
    final item = (await resolver.resolve('100 g de quiabo frito')).single;
    expect(item.food!.name, 'Quiabo, cru');
    expect(item.grams, 100);
    expect(item.oilGrams, 15);
    expect((await resolver.oilFood())!.name, 'Óleo, de soja');
  });

  test('alimento que já traz o preparo no nome não recebe óleo', () async {
    final egg = (await resolver.resolve('2 ovos fritos')).single;
    expect(egg.food!.name, 'Ovo, de galinha, inteiro, frito');
    expect(egg.oilGrams, isNull);
    final chicken = (await resolver.resolve('120 g de frango grelhado')).single;
    expect(chicken.food!.name, contains('grelhado'));
    expect(chicken.oilGrams, isNull);
  });

  test('medida sem conversão conhecida fica sem gramas', () async {
    final item = (await resolver.resolve('2 ovos fritos')).single;
    expect(item.grams, isNull);
    final spoon = (await resolver.resolve('2 colheres de sopa de arroz'))
        .single;
    expect(spoon.grams, isNull);
  });

  test('medida do usuário com o mesmo nome resolve a quantidade', () async {
    await MeasureRepository(db)
        .addUserMeasure(foodId: 'taco:490', label: 'unidade', grams: 50);
    await MeasureRepository(
      db,
    ).addUserMeasure(foodId: riceId, label: 'Colher de sopa cheia', grams: 25);
    expect((await resolver.resolve('2 ovos fritos')).single.grams, 100);
    final rice = (await resolver.resolve(
      '3 colheres de sopa de arroz integral',
    )).single;
    expect(rice.food!.id, riceId);
    expect(rice.grams, 75);
  });

  test('volume e item sem quantidade ficam sem gramas', () async {
    final items = await resolver.resolve(
      '200 ml de leite integral, banana prata',
    );
    expect(items, hasLength(2));
    expect(items.every((item) => item.food != null), isTrue);
    expect(items.every((item) => item.grams == null), isTrue);
  });

  test('alimento desconhecido volta sem proposta', () async {
    final item = (await resolver.resolve('100 g de xyzxyz')).single;
    expect(item.food, isNull);
    expect(item.candidates, isEmpty);
    expect(item.grams, isNull);
    expect(item.oilGrams, isNull);
  });

  test('trocar o alimento recalcula a medida para o novo alimento', () async {
    await MeasureRepository(db)
        .addUserMeasure(foodId: riceId, label: 'concha', grams: 90);
    final item = (await resolver.resolve('1 concha de arroz integral')).single;
    expect(item.grams, 90);
    final raw = item.candidates.firstWhere((food) => food.id != riceId);
    expect(await resolver.gramsFor(item.parsed, raw), isNull);
  });
}
