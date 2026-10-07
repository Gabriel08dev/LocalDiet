import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';
import 'tour.dart';

/// Percorre o app em telas pequenas e com fonte ampliada.
///
/// Qualquer conteúdo que estoure o espaço disponível gera uma exceção de
/// layout no Flutter, e o teste falha.
void main() {
  const cases = [
    (name: 'tela comum', size: Size(390, 844), scale: 1.0),
    (name: '320 px de largura', size: Size(320, 568), scale: 1.0),
    (name: '320 px com fonte ampliada', size: Size(320, 568), scale: 1.5),
    (
      name: 'tela comum com fonte muito ampliada',
      size: Size(390, 844),
      scale: 2.0,
    ),
  ];

  for (final testCase in cases) {
    testWidgets('telas não estouram: ${testCase.name}', (tester) async {
      final db = await pumpApp(
        tester,
        size: testCase.size,
        textScale: testCase.scale,
        seed: seedSampleData,
      );
      await tourApp(tester, (name) async {
        expect(tester.takeException(), isNull, reason: 'tela $name');
      });
      await closeApp(tester, db);
    });

    testWidgets('onboarding não estoura: ${testCase.name}', (tester) async {
      final db = await pumpApp(
        tester,
        onboarded: false,
        size: testCase.size,
        textScale: testCase.scale,
      );
      await tester.scrollUntilVisible(
        find.text('Começar'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await closeApp(tester, db);
    });
  }
}
