import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localdiet/data/repositories/diary_repository.dart';
import 'package:localdiet/data/repositories/plan_repository.dart';
import 'package:localdiet/data/repositories/profile_repository.dart';
import 'package:localdiet/domain/local_date.dart';
import 'package:localdiet/domain/profile_enums.dart';
import 'package:localdiet/ui/theme/app_theme.dart';
import 'package:localdiet/ui/widgets/common.dart';

import 'harness.dart';

const _riceId = 'taco:1';
const _rice = 'Arroz, integral, cozido';
const _milk = 'Leite, de vaca, integral';

/// O menu "Mais opções" do bloco de uma refeição no Diário.
Finder _menuOf(String meal) => find.descendant(
  of: find.widgetWithText(MealBlock, meal),
  matching: find.byTooltip('Mais opções'),
);

/// Casos que já falharam e foram corrigidos. Cada teste descreve o que o
/// usuário fazia quando o problema aparecia.
void main() {
  testWidgets('Diário: seguir o plano pelo menu registra e pode desfazer', (
    tester,
  ) async {
    final db = await pumpApp(
      tester,
      seed: (db) async {
        await PlanRepository(db)
            .addItems(MealType.lunch, [await portionOfFood(db, _riceId, 150)]);
      },
    );
    await openTab(tester, 'Diário');
    await tester.tap(_menuOf('Almoço'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Segui o plano'));
    await tester.pumpAndSettle();

    expect(find.text(_rice), findsOneWidget);
    expect(find.textContaining('Plano seguido'), findsOneWidget);
    expect(find.text('Almoço registrado conforme o plano'), findsOneWidget);

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(find.text(_rice), findsNothing);
    expect(find.textContaining('Plano seguido'), findsNothing);
    await closeApp(tester, db);
  });

  testWidgets('Diário: copiar de outro dia pelo menu traz a refeição', (
    tester,
  ) async {
    final db = await pumpApp(
      tester,
      seed: (db) async {
        await DiaryRepository(db).addItems(
          testToday.addDays(-1),
          MealType.dinner,
          [await portionOfFood(db, _riceId, 100)],
        );
      },
    );
    await openTab(tester, 'Diário');
    await tester.tap(_menuOf('Almoço'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copiar de outro dia'));
    await tester.pumpAndSettle();

    expect(find.text('Copiar para Almoço'), findsOneWidget);
    await tester.tap(find.text('Ontem · Jantar'));
    await tester.pumpAndSettle();

    expect(find.text('1 item copiado'), findsOneWidget);
    expect(find.text(_rice), findsOneWidget);
    final items = await tester.runAsync(
      () => DiaryRepository(db).watchDay(testToday).first,
    );
    expect(items!.single.meal, MealType.lunch);
    await closeApp(tester, db);
  });

  testWidgets('ao voltar ao app em outro dia, o Início passa para o novo dia', (
    tester,
  ) async {
    var now = testToday;
    final db = await pumpApp(
      tester,
      today: () => now,
      seed: (db) async {
        await DiaryRepository(db).addItems(testToday, MealType.lunch, [
          await portionOfFood(db, _riceId, 100),
        ]);
      },
    );
    expect(find.textContaining('1 item'), findsOneWidget);

    now = testToday.addDays(1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.textContaining('1 item'), findsNothing);

    // O Diário abre no novo dia, e o registro continua no dia em que foi feito.
    await openTab(tester, 'Diário');
    expect(find.widgetWithText(AppBar, 'Hoje'), findsOneWidget);
    expect(find.text(_rice), findsNothing);
    await tester.tap(find.text('${testToday.day}'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Ontem'), findsOneWidget);
    expect(find.text(_rice), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('seguir o plano com dois toques seguidos registra uma vez só', (
    tester,
  ) async {
    final db = await pumpApp(
      tester,
      seed: (db) async {
        await PlanRepository(db)
            .addItems(MealType.lunch, [await portionOfFood(db, _riceId, 150)]);
      },
    );
    final follow = find.text('Segui o plano');
    await tester.ensureVisible(follow);
    await tester.pumpAndSettle();
    await tester.tap(follow);
    await tester.tap(follow, warnIfMissed: false);
    await tester.pumpAndSettle();

    final items = await tester.runAsync(
      () => DiaryRepository(db).watchDay(testToday).first,
    );
    expect(items, hasLength(1));
    await closeApp(tester, db);
  });

  testWidgets('medição: dois toques em Salvar gravam uma medição só', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await openTab(tester, 'Evolução');
    await tester.tap(find.text('Nova medição'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Peso'), '81');
    final save = find.widgetWithText(FilledButton, 'Salvar');
    await tester.tap(save);
    await tester.tap(save, warnIfMissed: false);
    await tester.pumpAndSettle();

    final rows = await tester.runAsync(
      () => BodyRepository(db).watchAll().first,
    );
    expect(rows, hasLength(2), reason: 'a do perfil inicial e a nova');
    await closeApp(tester, db);
  });

  testWidgets('alimento sem energia na TACO não aparece como 0 kcal', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await tester.ensureVisible(find.byTooltip('Adicionar a Café da manhã'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Adicionar a Café da manhã'));
    await tester.pumpAndSettle();
    await searchFood(tester, 'leite de vaca integral');

    // Na lista, o leite diz que a fonte não informa a energia.
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, _milk),
        matching: find.text('Energia não informada na TACO'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text(_milk));
    await tester.pumpAndSettle();
    expect(find.text('Energia não informada'), findsOneWidget);
    expect(find.text('0 kcal'), findsNothing);
    expect(find.textContaining('crie o seu alimento'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('sal tem energia "não aplicável": aparece como 0, sem aviso', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await tester.ensureVisible(find.byTooltip('Adicionar a Almoço'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Adicionar a Almoço'));
    await tester.pumpAndSettle();
    await searchFood(tester, 'sal grosso');
    await tester.tap(find.text('Sal, grosso'));
    await tester.pumpAndSettle();

    expect(find.text('Energia não informada'), findsNothing);
    expect(find.text('0 kcal'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('alimento da TACO não abre na tela de edição', (tester) async {
    final db = await pumpApp(tester);
    GoRouter.of(tester.element(find.byType(NavigationBar)))
        .push('/food/edit/$_riceId');
    await tester.pumpAndSettle();

    expect(find.text('Alimento não encontrado'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Nome'), findsNothing);
    await closeApp(tester, db);
  });

  testWidgets('item deslizado some na hora, antes de a exclusão terminar', (
    tester,
  ) async {
    var deleted = 0;
    Widget block(List<String> ids) => MaterialApp(
      theme: buildTheme(Brightness.light),
      home: Scaffold(
        body: ListView(
          children: [
            MealBlock(
              title: 'Almoço',
              icon: Icons.restaurant,
              onAdd: () {},
              lines: [
                for (final id in ids)
                  MealLine(
                    id: id,
                    title: 'Arroz $id',
                    subtitle: '100 g',
                    kcal: 124,
                    onTap: () {},
                    onDelete: () => deleted++,
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(block(['a', 'b']));
    await tester.drag(find.text('Arroz a'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(deleted, 1);
    expect(find.text('Arroz a'), findsNothing);
    expect(find.text('Arroz b'), findsOneWidget);

    // A tela é reconstruída antes de o banco tirar o item da lista.
    await tester.pumpWidget(block(['a', 'b']));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Arroz a'), findsNothing);

    // O banco confirma a exclusão; depois o usuário desfaz e o item volta.
    await tester.pumpWidget(block(['b']));
    await tester.pumpWidget(block(['a', 'b']));
    await tester.pumpAndSettle();
    expect(find.text('Arroz a'), findsOneWidget);
  });

  testWidgets('o seletor de data abre com o dia fora do intervalo padrão', (
    tester,
  ) async {
    const outside = LocalDate(2030, 1, 5);
    LocalDate? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              picked = await pickDate(
                context,
                initial: outside,
                first: const LocalDate(2000, 1, 1),
                last: const LocalDate(2027, 1, 1),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(picked, outside);
  });
}
