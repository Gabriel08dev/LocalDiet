import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';
import 'strings.dart';

final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    routes: [GoRoute(path: '/', builder: (context, state) => const _Boot())],
  ),
);

class _Boot extends ConsumerWidget {
  const _Boot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boot = ref.watch(bootstrapProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(S.appName)),
      body: Center(
        child: boot.when(
          data: (_) => const Text('Base de alimentos pronta.'),
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => Text('$error'),
        ),
      ),
    );
  }
}
