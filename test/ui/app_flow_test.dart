import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localdiet/data/repositories/diary_repository.dart';
import 'package:localdiet/data/repositories/plan_repository.dart';
import 'package:localdiet/data/repositories/profile_repository.dart';
import 'package:localdiet/domain/profile_enums.dart';
import 'package:localdiet/ui/widgets/trend_chart.dart';

import 'harness.dart';

void main() {
  testWidgets('primeira abertura pede o perfil e depois abre o Início', (
    tester,
  ) async {
    final db = await pumpApp(tester, onboarded: false);
    expect(find.text('Vamos começar'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Ana');
    await tester.tap(find.text('Data de nascimento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1996'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('15/01/1996'), findsOneWidget);
    await tester.tap(find.text('Feminino'));
    await tester.pump();

    await tester.enterText(find.widgetWithText(TextFormField, 'Altura'), '165');
    await tester.enterText(find.widgetWithText(TextFormField, 'Peso'), '60,5');
    await tester.scrollUntilVisible(
      find.text('Começar'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Ana'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    final measurements = await tester.runAsync(
      () => BodyRepository(db).watchAll().first,
    );
    expect(measurements!.single.weightKg, 60.5);
    await closeApp(tester, db);
  });

  testWidgets('onboarding incompleto mostra o que falta e não avança', (
    tester,
  ) async {
    final db = await pumpApp(tester, onboarded: false);
    await tester.scrollUntilVisible(
      find.text('Começar'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Preencha este campo', skipOffstage: false), findsWidgets);
    expect(find.text('Escolha uma opção', skipOffstage: false), findsOneWidget);
    final profile = await tester.runAsync(
      () => ProfileRepository(db).watch().first,
    );
    expect(profile, isNull);
    await closeApp(tester, db);
  });

  testWidgets('busca, porção, revisão e Diário: 252 g de arroz integral', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    expect(find.text('Olá, Gabriel'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Adicionar a Almoço'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Adicionar a Almoço'));
    await tester.pumpAndSettle();
    await searchFood(tester, 'arroz integral');
    await tester.tap(find.text('Arroz, integral, cozido'));
    await tester.pumpAndSettle();

    // Para um alimento nunca registrado, a folha abre na primeira medida
    // caseira: 1 colher de sopa de arroz integral, 20 g.
    expect(find.text('25 kcal'), findsOneWidget);
    expect(find.text('= 20 g'), findsOneWidget);
    await tester.tap(find.text('gramas'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, '252');
    await tester.pump();
    expect(find.text('312 kcal'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('1 item · 312 kcal'), findsOneWidget);
    await tester.tap(find.text('Revisar'));
    await tester.pumpAndSettle();
    expect(find.text('Total da refeição'), findsOneWidget);
    await tester.tap(find.text('Salvar em Almoço'));
    await tester.pumpAndSettle();

    // De volta ao Início, o dia já reflete o registro.
    expect(find.text('312'), findsOneWidget);
    expect(find.text('1 item · 312 kcal'), findsOneWidget);

    await openTab(tester, 'Diário');
    expect(find.text('Arroz, integral, cozido'), findsOneWidget);
    expect(find.text('252 g'), findsOneWidget);

    // Editar a porção para 100 g.
    await tester.tap(find.text('Arroz, integral, cozido'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '100');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('100 g'), findsOneWidget);

    // Excluir deslizando e desfazer.
    await tester.drag(
      find.text('Arroz, integral, cozido'),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Arroz, integral, cozido'), findsNothing);
    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(find.text('Arroz, integral, cozido'), findsOneWidget);

    await closeApp(tester, db);
  });

  testWidgets('a folha de porção reabre na última porção usada', (
    tester,
  ) async {
    final db = await pumpApp(
      tester,
      seed: (db) async {
        await DiaryRepository(db).addItems(
          testToday.addDays(-1),
          MealType.lunch,
          [await portionOfFood(db, 'taco:1', 180)],
        );
      },
    );
    await tester.ensureVisible(find.byTooltip('Adicionar a Jantar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Adicionar a Jantar'));
    await tester.pumpAndSettle();
    // O alimento aparece nos recentes antes de qualquer digitação.
    expect(find.text('Recentes'), findsOneWidget);
    await tester.tap(find.text('Arroz, integral, cozido'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '180'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('sair com alimentos não salvos pede confirmação', (tester) async {
    final db = await pumpApp(tester);
    await tester.ensureVisible(find.byTooltip('Adicionar a Lanche'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Adicionar a Lanche'));
    await tester.pumpAndSettle();
    await searchFood(tester, 'banana prata');
    await tester.tap(find.text('Banana, prata, crua'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Descartar esta refeição?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Revisar'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    // De volta ao Início, sem a refeição em montagem.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Revisar'), findsNothing);
    final saved = await tester.runAsync(
      () => DiaryRepository(db).watchDay(testToday).first,
    );
    expect(saved, isEmpty);
    await closeApp(tester, db);
  });

  testWidgets('sem Plano Base não há meta de macros; com plano há', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    expect(find.textContaining('Monte um Plano Base'), findsOneWidget);
    expect(find.textContaining(' de 8 g'), findsNothing);

    await tester.runAsync(() async {
      await PlanRepository(db)
          .addItems(MealType.lunch, [await portionOfFood(db, 'taco:1', 300)]);
    });
    await tester.pumpAndSettle();
    expect(find.textContaining('Monte um Plano Base'), findsNothing);
    // 300 g de arroz integral: 7,8 g de proteína planejada.
    expect(find.text('0 de 8 g'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('consumo acima da meta aparece como excedente', (tester) async {
    final db = await pumpApp(
      tester,
      seed: (db) async {
        await ProfileRepository(db).save(
          name: 'Gabriel',
          birthDate: testToday.addDays(-11000),
          sex: Sex.male,
          heightCm: 178,
          goal: Goal.maintain,
          activity: ActivityLevel.moderate,
          manualKcalTarget: 2000,
        );
        await DiaryRepository(db).addItems(testToday, MealType.lunch, [
          await portionOfFood(db, 'taco:2', 600),
        ]);
      },
    );
    // 600 g de arroz integral cru: 2.160 kcal contra a meta de 2.000.
    expect(find.text('Excedente hoje'), findsOneWidget);
    expect(find.text('160 kcal'), findsOneWidget);
    expect(find.textContaining('Restam'), findsNothing);
    await closeApp(tester, db);
  });

  testWidgets('Plano Base: adicionar pelo mesmo fluxo de busca', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await openTab(tester, 'Plano');
    expect(
      find.textContaining('O Plano Base é a sua dieta planejada'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byTooltip('Adicionar a Café da manhã'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Adicionar a Café da manhã'));
    await tester.pumpAndSettle();
    await searchFood(tester, 'pao frances');
    await tester.tap(find.text('Pão, trigo, francês'));
    await tester.pumpAndSettle();
    // A folha já abre em 1 unidade de pão francês, 50 g.
    expect(find.text('unidade · 50 g'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revisar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar no plano: Café da manhã'));
    await tester.pumpAndSettle();

    expect(find.text('Total planejado para o dia'), findsOneWidget);
    expect(find.text('Pão, trigo, francês'), findsOneWidget);
    expect(find.text('150 kcal'), findsWidgets);
    final diary = await tester.runAsync(
      () => DiaryRepository(db).watchDay(testToday).first,
    );
    expect(diary, isEmpty, reason: 'o plano não registra consumo');
    await closeApp(tester, db);
  });

  testWidgets('Evolução: uma medição não desenha gráfico, duas desenham', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await openTab(tester, 'Evolução');
    expect(find.byType(TrendChart), findsNothing);
    expect(
      find.text('Registre mais uma medição para ver a evolução em gráfico.'),
      findsWidgets,
    );

    await tester.tap(find.text('Nova medição'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Peso'), '81,3');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(find.byType(TrendChart), findsOneWidget);
    expect(find.text('81,3 kg'), findsWidgets);
    expect(find.textContaining('−1,2 kg desde'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('medição vazia não é salva', (tester) async {
    final db = await pumpApp(tester);
    await openTab(tester, 'Evolução');
    await tester.tap(find.text('Nova medição'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Preencha ao menos uma medida.'), findsOneWidget);
    final rows = await tester.runAsync(
      () => BodyRepository(db).watchAll().first,
    );
    expect(rows, hasLength(1));
    await closeApp(tester, db);
  });

  testWidgets('texto livre: proposta conferida antes de entrar na refeição', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await tester.ensureVisible(find.byTooltip('Adicionar a Almoço'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Adicionar a Almoço'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descrever em texto'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).last,
      '100 g de quiabo frito, 2 ovos fritos, 2 jilós',
    );
    await tester.pump();
    await tester.tap(find.text('Interpretar'));
    await tester.pumpAndSettle();

    // O quiabo da TACO não tem "frito" no nome: o app sugere óleo, rotulado como
    // estimativa. O ovo frito da TACO já inclui o preparo: sem óleo.
    expect(find.text('Quiabo, cru'), findsOneWidget);
    expect(find.text('Óleo, de soja'), findsOneWidget);
    expect(find.textContaining('estimativa do app'), findsOneWidget);
    expect(find.text('Ovo, de galinha, inteiro, frito'), findsOneWidget);

    // O jiló não tem medida caseira: sem gramas, não dá para seguir.
    expect(find.text('Jiló, cru'), findsOneWidget);
    final confirm = find.widgetWithText(FilledButton, 'Adicionar à refeição');
    await tester.ensureVisible(confirm);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    expect(
      find.text('Não foi possível determinar a quantidade. Informe os gramas.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Gramas').last,
      '100',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(confirm);
    await tester.pumpAndSettle();
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    // Os itens vão para a revisão; nada foi salvo ainda.
    expect(find.text('Revisar refeição'), findsOneWidget);
    expect(find.textContaining('15 g · estimativa'), findsOneWidget);
    final saved = await tester.runAsync(
      () => DiaryRepository(db).watchDay(testToday).first,
    );
    expect(saved, isEmpty);
    await closeApp(tester, db);
  });

  testWidgets('Perfil: meta manual substitui a calculada e pode ser desfeita', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await openTab(tester, 'Perfil');
    expect(find.text('Meta de calorias calculada'), findsOneWidget);

    await tester.tap(find.text('Definir meta manual'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, '1900');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Meta de calorias manual'), findsOneWidget);
    expect(find.text('1.900 kcal por dia'), findsOneWidget);

    await tester.tap(find.text('Voltar à meta calculada'));
    await tester.pumpAndSettle();
    expect(find.text('Meta de calorias calculada'), findsOneWidget);
    await closeApp(tester, db);
  });
}
