import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Configuração comum a todos os testes.
///
/// Carrega as fontes reais do Material. Sem isso, o `flutter_test` desenha
/// todo texto e ícone como blocos, e as capturas de tela não servem para
/// conferir o layout. Este arquivo só afeta os testes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await _loadMaterialFonts();
  await testMain();
}

Future<void> _loadMaterialFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) return;
  final directory = Directory(
    '$flutterRoot/bin/cache/artifacts/material_fonts',
  );
  if (!directory.existsSync()) return;

  Future<ByteData> read(File file) async =>
      ByteData.view(file.readAsBytesSync().buffer);

  final files = directory.listSync().whereType<File>().toList();
  final roboto = FontLoader('Roboto');
  for (final file in files) {
    final name = file.uri.pathSegments.last.toLowerCase();
    if (name.startsWith('roboto-') && name.endsWith('.ttf')) {
      roboto.addFont(read(file));
    }
  }
  await roboto.load();

  final icons = FontLoader('MaterialIcons');
  for (final file in files) {
    if (file.uri.pathSegments.last.toLowerCase().startsWith('materialicons-')) {
      icons.addFont(read(file));
    }
  }
  await icons.load();
}
