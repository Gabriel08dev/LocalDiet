import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';
import 'tour.dart';

/// Gera as capturas de `docs/screenshots/`.
///
/// Não é um teste de regressão: as imagens variam de um sistema para outro,
/// então este arquivo só roda quando pedido, com
/// `flutter test --update-goldens test/ui/screenshots_test.dart`.
void main() {
  const size = Size(390, 844);

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    final folder = mode == ThemeMode.light ? 'claro' : 'escuro';

    testWidgets('capturas, tema $folder', (tester) async {
      final db = await pumpApp(
        tester,
        size: size,
        pixelRatio: 2,
        themeMode: mode,
        seed: seedSampleData,
      );
      await tourApp(tester, (name) async {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../../docs/screenshots/$folder/$name.png'),
        );
      });
      await closeApp(tester, db);
    }, skip: !autoUpdateGoldenFiles);

    testWidgets('captura do onboarding, tema $folder', (tester) async {
      final db = await pumpApp(
        tester,
        onboarded: false,
        size: size,
        pixelRatio: 2,
        themeMode: mode,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../docs/screenshots/$folder/00_onboarding.png'),
      );
      await closeApp(tester, db);
    }, skip: !autoUpdateGoldenFiles);
  }
}
