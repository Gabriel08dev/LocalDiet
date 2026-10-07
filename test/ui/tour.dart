import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/data/app_database.dart';
import 'package:localdiet/data/repositories/diary_repository.dart';
import 'package:localdiet/data/repositories/food_repository.dart';
import 'package:localdiet/data/repositories/measure_repository.dart';
import 'package:localdiet/data/repositories/plan_repository.dart';
import 'package:localdiet/data/repositories/profile_repository.dart';
import 'package:localdiet/domain/nutrients.dart';
import 'package:localdiet/domain/portion.dart';
import 'package:localdiet/domain/profile_enums.dart';

import 'harness.dart';

Future<FoodPortion> _byName(AppDatabase db, String query, double grams) async {
  final food = (await FoodRepository(db).search(query)).first;
  return FoodPortion(
    foodId: food.id,
    foodName: food.name,
    per100: food.per100,
    portion: Portion.grams(grams),
  );
}

/// Dados de exemplo que deixam todas as telas com conteúdo.
Future<void> seedSampleData(AppDatabase db) async {
  final foods = FoodRepository(db);
  final diary = DiaryRepository(db);
  final plan = PlanRepository(db);
  final body = BodyRepository(db);

  final wheyId = await foods.saveUserFood(
    name: 'Whey protein baunilha',
    per100: const Nutrients(
      kcal: 380,
      protein: 78,
      carb: 8,
      fat: 5,
      sodium: 210,
    ),
  );
  await MeasureRepository(db)
      .addUserMeasure(foodId: wheyId, label: 'scoop', grams: 30);
  final whey = (await foods.byId(wheyId))!;
  final wheyPortion = FoodPortion(
    foodId: whey.id,
    foodName: whey.name,
    per100: whey.per100,
    portion: const Portion(
      measureLabel: 'scoop',
      measureGrams: 30,
      quantity: 1,
    ),
  );

  await diary.addItems(testToday.addDays(-1), MealType.dinner, [
    await _byName(db, 'arroz integral cozido', 120),
    await _byName(db, 'frango peito grelhado', 150),
  ]);
  await diary.addItems(testToday, MealType.breakfast, [
    await _byName(db, 'pao frances', 50),
    await _byName(db, 'banana prata', 90),
    wheyPortion,
  ]);
  await diary.addItems(testToday, MealType.lunch, [
    await _byName(db, 'arroz integral cozido', 150),
    await _byName(db, 'feijao carioca cozido', 100),
    await _byName(db, 'frango peito grelhado', 130),
  ]);

  await plan.addItems(MealType.breakfast, [
    await _byName(db, 'pao frances', 50),
    wheyPortion,
  ]);
  await plan.addItems(MealType.lunch, [
    await _byName(db, 'arroz integral cozido', 180),
    await _byName(db, 'feijao carioca cozido', 120),
    await _byName(db, 'frango peito grelhado', 150),
  ]);
  await plan.addItems(MealType.dinner, [
    await _byName(db, 'arroz integral cozido', 150),
    await _byName(db, 'frango peito grelhado', 150),
  ]);

  await body.save(date: testToday.addDays(-20), weightKg: 82.0, waistCm: 89.5);
  await body.save(date: testToday.addDays(-9), weightKg: 81.4, waistCm: 89);
  await body.save(date: testToday, weightKg: 80.9, waistCm: 88, neckCm: 39);

  final banana = (await foods.search('banana prata')).first;
  await foods.setFavorite(banana.id, favorite: true);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    // Listas só constroem o que está perto da área visível: rola a lista da
    // tela atual até o item existir.
    final lists = find.byWidgetPredicate(
      (widget) =>
          widget is ListView ||
          (widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.vertical),
    );
    if (lists.evaluate().isEmpty) fail('Sem lista para rolar até $finder');
    final scrollable = find
        .descendant(of: lists.last, matching: find.byType(Scrollable))
        .first;
    // O item pode estar acima ou abaixo: volta ao topo e desce procurando.
    await tester.drag(scrollable, const Offset(0, 5000));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(finder, 200, scrollable: scrollable);
  }
  expect(finder, findsWidgets);
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

/// Percorre as telas principais do app, chamando [shot] em cada uma.
///
/// Serve a dois testes: o de layout, que só precisa que nenhuma tela estoure
/// o espaço disponível, e o de capturas, que grava uma imagem por tela.
Future<void> tourApp(
  WidgetTester tester,
  Future<void> Function(String name) shot,
) async {
  await shot('01_inicio');

  await openTab(tester, 'Diário');
  await shot('02_diario');

  await _tap(tester, find.byTooltip('Adicionar a Almoço'));
  await shot('03_busca_sugestoes');
  await searchFood(tester, 'arroz');
  await shot('04_busca_resultados');
  await _tap(tester, find.text('Arroz, integral, cozido'));
  await shot('05_porcao');
  await _tap(tester, find.widgetWithText(FilledButton, 'Adicionar'));
  await _tap(tester, find.text('Revisar'));
  await shot('06_revisao');
  await _tap(tester, find.text('Adicionar mais alimentos'));
  await _tap(tester, find.text('Descrever em texto'));
  await tester.enterText(
    find.byType(TextField).last,
    '100 g de quiabo frito e 150 g de arroz integral',
  );
  await tester.pump();
  await _tap(tester, find.text('Interpretar'));
  await shot('07_texto_livre');
  await _back(tester);
  await _tap(tester, find.byType(BackButton));
  await _tap(tester, find.text('Descartar'));

  await _tap(tester, find.text('Whey protein baunilha'));
  await shot('08_porcao_do_usuario');
  await _tap(tester, find.byTooltip('Ficha do alimento'));
  await shot('09_ficha');
  await _back(tester);
  await _back(tester);

  await openTab(tester, 'Plano');
  await shot('10_plano');

  await openTab(tester, 'Evolução');
  await shot('11_evolucao');
  await _tap(tester, find.text('Nova medição'));
  await shot('12_nova_medicao');
  await _back(tester);

  await openTab(tester, 'Perfil');
  await shot('13_perfil');
  await _tap(tester, find.text('Dados pessoais'));
  await shot('14_dados_pessoais');
  await _back(tester);
  await _tap(tester, find.text('Meus alimentos'));
  await shot('15_meus_alimentos');
  await _tap(tester, find.text('Whey protein baunilha'));
  await shot('16_editar_alimento');
  await _back(tester);
  await _back(tester);
  await _tap(tester, find.text('Exportar e importar dados'));
  await shot('17_dados');
  await _back(tester);
  await _tap(tester, find.text('Sobre e fontes'));
  await shot('18_sobre');
  await _back(tester);
}
