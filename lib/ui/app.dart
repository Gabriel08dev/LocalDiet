import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'router.dart';
import 'strings.dart';
import 'theme/app_theme.dart';

class LocalDietApp extends ConsumerStatefulWidget {
  const LocalDietApp({super.key});

  @override
  ConsumerState<LocalDietApp> createState() => _LocalDietAppState();
}

/// Além de montar o app, mantém o "hoje" em dia.
///
/// O processo pode ficar vivo por dias em segundo plano. Sem isto, o Início e
/// os novos registros continuariam no dia em que o app foi aberto. A data é
/// conferida quando o app volta ao primeiro plano e logo após a meia-noite.
class _LocalDietAppState extends ConsumerState<LocalDietApp>
    with WidgetsBindingObserver {
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnight();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnight?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshToday();
  }

  void _refreshToday() {
    // Se o dia não mudou, o valor recalculado é igual e nada é reconstruído.
    ref.invalidate(todayProvider);
    _scheduleMidnight();
  }

  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(
      nextDay.difference(now) + const Duration(seconds: 1),
      _refreshToday,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    return MaterialApp.router(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeMode,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
