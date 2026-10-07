import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/data/app_database.dart';
import 'package:localdiet/data/repositories/diary_repository.dart';
import 'package:localdiet/data/repositories/food_repository.dart';
import 'package:localdiet/data/repositories/plan_repository.dart';
import 'package:localdiet/data/tables.dart';
import 'package:localdiet/domain/nutrients.dart';
import 'package:localdiet/domain/portion.dart';
import 'package:localdiet/domain/profile_enums.dart';
import 'package:localdiet/ui/format.dart';

import 'harness.dart';

/// Um item do plano em medida caseira, como o usuário montaria.
Future<FoodPortion> _planned(
  AppDatabase db,
  String query,
  String measure,
  double grams,
  double quantity,
) async {
  final food = (await FoodRepository(db).search(query)).first;
  return FoodPortion(
    foodId: food.id,
    foodName: food.name,
    per100: food.per100,
    portion: Portion(
      measureLabel: measure,
      measureGrams: grams,
      quantity: quantity,
    ),
  );
}

/// O Plano Base de quem usa o app neste roteiro.
Future<void> _seedPlan(AppDatabase db) async {
  final plan = PlanRepository(db);
  await plan.addItems(MealType.breakfast, [
    await _planned(db, 'pao frances', 'unidade', 50, 1),
    await _planned(db, 'ovo galinha inteiro frito', 'unidade', 50, 2),
  ]);
  await plan.addItems(MealType.lunch, [
    await _planned(db, 'arroz tipo 1 cozido', 'colher de servir', 45, 3),
    await _planned(db, 'feijao carioca cozido', 'concha', 140, 1),
    await _planned(db, 'frango peito sem pele grelhado', 'filé', 100, 1),
  ]);
  await plan.addItems(MealType.dinner, [
    await _planned(db, 'arroz tipo 1 cozido', 'colher de servir', 45, 2),
    await _planned(db, 'frango peito sem pele grelhado', 'filé', 100, 1),
  ]);
}

Future<void> _shot(WidgetTester tester, String name) async {
  if (!autoUpdateGoldenFiles) return;
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../docs/screenshots/dia/$name.png'),
  );
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

/// Escolhe um alimento na busca e adiciona [quantity] da medida [chip].
/// Devolve quantos toques e digitações foram necessários.
Future<int> _addFromSearch(
  WidgetTester tester, {
  required String query,
  required String food,
  required String chip,
  int quantity = 1,
}) async {
  await searchFood(tester, query);
  await _tap(tester, find.text(food));
  await _tap(tester, find.text(chip));
  for (var count = 1; count < quantity; count++) {
    await _tap(tester, find.byTooltip('Aumentar'));
  }
  await _tap(tester, find.widgetWithText(FilledButton, 'Adicionar'));
  // Digitar a busca, tocar no alimento, na medida, nos incrementos e em
  // Adicionar.
  return 1 + 1 + 1 + (quantity - 1) + 1;
}

/// Roteiro de um dia de uso, do café da manhã ao jantar.
///
/// É o teste do fluxo de registro como uma pessoa o faria: em medidas
/// caseiras, seguindo o plano em algumas refeições e trocando outras. Com
/// `--update-goldens`, grava uma captura de cada passo em
/// `docs/screenshots/dia/`.
void main() {
  testWidgets('um dia registrando as refeições em medidas caseiras', (
    tester,
  ) async {
    final db = await pumpApp(
      tester,
      pixelRatio: autoUpdateGoldenFiles ? 2 : 1,
      seed: _seedPlan,
    );
    Future<List<DiaryItemRow>> diary() async => (await tester.runAsync(
      () => DiaryRepository(db).watchDay(testToday).first,
    ))!;

    // Manhã: o Início mostra o que estava planejado e pergunta.
    expect(find.text('Segui o plano'), findsNWidgets(3));
    expect(find.text('Planejado: 2 itens · 390 kcal'), findsOneWidget);
    await _shot(tester, '01_inicio_com_plano');

    // Café da manhã: seguiu o plano. Um toque.
    await tester.tap(find.text('Segui o plano').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text('Café da manhã registrado conforme o plano'),
      findsOneWidget,
    );
    await _shot(tester, '02_cafe_seguiu_o_plano');
    expect(find.text('Plano seguido · 2 itens · 390 kcal'), findsOneWidget);
    var items = await diary();
    expect(items.map((item) => item.foodName), [
      'Pão, trigo, francês',
      'Ovo, de galinha, inteiro, frito',
    ]);
    expect(items.last.measureLabel, 'unidade');
    expect(items.last.quantity, 2);
    expect(items.last.grams, 100);

    // Almoço: comeu outra coisa, registrada pela busca em medidas caseiras.
    await _tap(tester, find.text('Comi outra coisa'));
    expect(find.text('Diário · Hoje'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Almoço'))
          .selected,
      isTrue,
    );
    await _shot(tester, '03_almoco_busca');

    await searchFood(tester, 'arroz');
    await _shot(tester, '04_almoco_resultados');
    await _tap(tester, find.text('Arroz, tipo 1, cozido'));
    // A folha abre em 1 colher de sopa; as medidas do IBGE estão à mão.
    expect(find.text('colher de sopa · 25 g'), findsOneWidget);
    expect(find.text('concha · 100 g'), findsOneWidget);
    await _tap(tester, find.text('colher de servir · 45 g'));
    await _tap(tester, find.byTooltip('Aumentar'));
    await _tap(tester, find.byTooltip('Aumentar'));
    await _tap(tester, find.byTooltip('Aumentar'));
    expect(find.text('= 180 g'), findsOneWidget);
    await _shot(tester, '05_almoco_porcao_em_colheres');
    await _tap(tester, find.widgetWithText(FilledButton, 'Adicionar'));

    // A busca volta vazia, pronta para o próximo alimento.
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      '',
    );
    var taps = await _addFromSearch(
      tester,
      query: 'feijao',
      food: 'Feijão, carioca, cozido',
      chip: 'concha · 140 g',
    );
    expect(taps, 4, reason: 'buscar, alimento, medida e Adicionar');
    taps = await _addFromSearch(
      tester,
      query: 'contra file grelhado',
      food: 'Carne, bovina, contra-filé, sem gordura, grelhado',
      chip: 'bife · 100 g',
    );
    expect(taps, 4);
    await _addFromSearch(
      tester,
      query: 'alface',
      food: 'Alface, crespa, crua',
      chip: 'folha · 10 g',
      quantity: 4,
    );
    await _tap(tester, find.text('Revisar'));
    expect(find.text('4 × colher de servir · 180 g'), findsOneWidget);
    expect(find.text('1 × concha · 140 g'), findsOneWidget);
    expect(find.text('4 × folha · 40 g'), findsOneWidget);
    await _shot(tester, '06_almoco_revisao');
    await _tap(tester, find.text('Salvar em Almoço'));
    expect(find.textContaining('Outra refeição · 4 itens'), findsOneWidget);

    // Lanche: descrito em texto, com medidas caseiras.
    await _tap(tester, find.byTooltip('Adicionar a Lanche'));
    await _tap(tester, find.text('Descrever em texto'));
    await tester.enterText(
      find.byType(TextField).last,
      '1 banana prata, 1 copo de leite integral e '
      '2 fatias de pão de forma integral',
    );
    await tester.pump();
    await _tap(tester, find.text('Interpretar'));
    expect(find.text('Banana, prata, crua'), findsOneWidget);
    expect(find.text('Pão, trigo, forma, integral'), findsOneWidget);
    // Tudo foi resolvido em gramas: nada pede digitação.
    expect(
      find.text('Não foi possível determinar a quantidade. Informe os gramas.'),
      findsNothing,
    );
    await _shot(tester, '07_lanche_em_texto');
    await _tap(
      tester,
      find.widgetWithText(FilledButton, 'Adicionar à refeição'),
    );
    await _shot(tester, '08_lanche_revisao');
    await _tap(tester, find.text('Salvar em Lanche'));

    items = await diary();
    final snack = {
      for (final item in items.where((item) => item.meal == MealType.snack))
        item.foodName: item.grams,
    };
    expect(snack, {
      'Banana, prata, crua': 75,
      'Leite, de vaca, integral': 240,
      'Pão, trigo, forma, integral': 50,
    });

    // Jantar: seguiu o plano e depois ajustou a quantidade no Diário.
    await _tap(tester, find.text('Segui o plano'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await _shot(tester, '09_inicio_fim_do_dia');
    await openTab(tester, 'Diário');
    await tester.scrollUntilVisible(
      find.text('Jantar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Plano seguido · 274 kcal'), findsOneWidget);
    await _tap(tester, find.text('2 × colher de servir · 90 g'));
    await _tap(tester, find.byTooltip('Diminuir'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Salvar'));
    expect(find.text('1 × colher de servir · 45 g'), findsOneWidget);
    await _shot(tester, '10_diario');

    // O dia inteiro: quatro refeições, nenhuma gramatura digitada.
    items = await diary();
    expect(items, hasLength(11));
    expect(items.where((item) => item.measureLabel == 'g'), isEmpty);
    final total = Nutrients.sum(items.map((item) => item.nutrients));
    await openTab(tester, 'Início');
    expect(find.text(formatInteger(total.kcal)), findsOneWidget);

    // A adesão do dia aparece no Plano.
    await openTab(tester, 'Plano');
    expect(
      find.text('Plano seguido em 2 de 3 refeições marcadas'),
      findsOneWidget,
    );
    expect(find.text('1 refeição trocada por outra.'), findsOneWidget);
    await _shot(tester, '11_plano_adesao');
    final checks = await tester.runAsync(
      () => PlanRepository(db).watchChecks(testToday).first,
    );
    expect(checks, {
      MealType.breakfast: PlanCheckStatus.followed,
      MealType.lunch: PlanCheckStatus.other,
      MealType.dinner: PlanCheckStatus.followed,
    });
    await closeApp(tester, db);
  });

  testWidgets('seguir o plano pode ser desfeito na hora', (tester) async {
    final db = await pumpApp(tester, seed: _seedPlan);
    await tester.tap(find.text('Segui o plano').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Segui o plano'), findsNWidgets(2));

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(find.text('Segui o plano'), findsNWidgets(3));
    final items = await tester.runAsync(
      () => DiaryRepository(db).watchDay(testToday).first,
    );
    expect(items, isEmpty);
    await closeApp(tester, db);
  });

  testWidgets('sem Plano Base o Início não pergunta nada', (tester) async {
    final db = await pumpApp(tester);
    expect(find.text('Segui o plano'), findsNothing);
    expect(find.text('Comi outra coisa'), findsNothing);
    expect(find.text('Nada registrado'), findsNWidgets(5));
    await closeApp(tester, db);
  });

  testWidgets('no Diário, o menu segue o plano e desmarca', (tester) async {
    final db = await pumpApp(tester, seed: _seedPlan);
    await openTab(tester, 'Diário');
    await tester.tap(find.byTooltip('Mais opções').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Segui o plano'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Plano seguido · 390 kcal'), findsOneWidget);

    await tester.tap(find.byTooltip('Mais opções').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desmarcar'));
    await tester.pumpAndSettle();
    expect(find.text('Plano seguido · 390 kcal'), findsNothing);
    // Desmarcar não apaga o que foi registrado.
    expect(find.text('Pão, trigo, francês'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('alimento próprio com scoop entra direto na medida', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await _tap(tester, find.byTooltip('Adicionar a Outro'));
    await _tap(tester, find.text('Criar alimento'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do alimento'),
      'Whey protein',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Energia'),
      '380',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Proteína'),
      '78',
    );
    final portionName = find.widgetWithText(TextFormField, 'Nome da porção');
    await tester.scrollUntilVisible(
      portionName,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.enterText(portionName, 'scoop');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Peso da porção'),
      '30',
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Salvar'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await _tap(tester, find.widgetWithText(FilledButton, 'Salvar'));

    // A folha de porção abre em 1 scoop do alimento recém-criado.
    expect(find.text('scoop · 30 g'), findsOneWidget);
    expect(find.text('114 kcal'), findsOneWidget);
    await _tap(tester, find.byTooltip('Aumentar'));
    expect(find.text('= 60 g'), findsOneWidget);
    await _tap(tester, find.widgetWithText(FilledButton, 'Adicionar'));
    await _tap(tester, find.text('Revisar'));
    expect(find.text('2 × scoop · 60 g'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('"Minha porção" sugere nomes como scoop e concha', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await _tap(tester, find.byTooltip('Adicionar a Lanche'));
    await searchFood(tester, 'jilo');
    await _tap(tester, find.text('Jiló, cru'));
    // Sem medida caseira na base: só gramas e a porção própria.
    expect(find.widgetWithText(TextField, '100'), findsOneWidget);
    await _tap(tester, find.text('Minha porção'));
    await _tap(tester, find.widgetWithText(ActionChip, 'unidade'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Peso da porção'),
      '18',
    );
    await _tap(tester, find.widgetWithText(FilledButton, 'Salvar'));
    expect(find.text('unidade · 18 g'), findsOneWidget);
    expect(find.text('= 18 g'), findsOneWidget);
    await closeApp(tester, db);
  });
}
