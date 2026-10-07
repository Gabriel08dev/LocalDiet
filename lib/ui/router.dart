import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/local_date.dart';
import '../domain/profile_enums.dart';
import '../providers.dart';
import 'screens/about_screen.dart';
import 'screens/data_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/evolution_screen.dart';
import 'screens/food_screens.dart';
import 'screens/home_screen.dart';
import 'screens/meal_builder_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/profile_form.dart';
import 'screens/profile_screen.dart';
import 'strings.dart';
import 'theme/app_theme.dart';
import 'widgets/common.dart';

final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            _AppGate(child: _Shell(shell: shell)),
        branches: [
          for (final (path, screen) in const <(String, Widget)>[
            ('/home', HomeScreen()),
            ('/diary', DiaryScreen()),
            ('/plan', PlanScreen()),
            ('/evolution', EvolutionScreen()),
            ('/profile', ProfileScreen()),
          ])
            StatefulShellBranch(
              routes: [
                GoRoute(path: path, builder: (context, state) => screen),
              ],
            ),
        ],
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) {
          final query = state.uri.queryParameters;
          return MealBuilderScreen(
            target: query['target'] == 'plan'
                ? AddTarget.plan
                : AddTarget.diary,
            meal: MealType.values.firstWhere(
              (meal) => meal.name == query['meal'],
              orElse: () => MealType.other,
            ),
            date:
                LocalDate.tryParse(query['date'] ?? '') ??
                ref.read(todayProvider),
          );
        },
      ),
      GoRoute(
        path: '/food/new',
        builder: (context, state) =>
            CustomFoodScreen(initialName: state.uri.queryParameters['name']),
      ),
      GoRoute(
        path: '/food/edit/:id',
        builder: (context, state) =>
            CustomFoodScreen(foodId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/food/view/:id',
        builder: (context, state) =>
            FoodDetailScreen(foodId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/my-foods',
        builder: (context, state) => const MyFoodsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(path: '/data', builder: (context, state) => const DataScreen()),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    ],
  ),
);

/// Segura a entrada no app até a base de alimentos estar sincronizada e,
/// sem perfil, mostra o onboarding.
class _AppGate extends ConsumerWidget {
  const _AppGate({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boot = ref.watch(bootstrapProvider);
    if (boot.hasError) {
      return Scaffold(
        body: Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: S.bootFailed,
            message: S.bootFailedHelp,
            action: FilledButton(
              onPressed: () => ref.invalidate(bootstrapProvider),
              child: const Text(S.tryAgain),
            ),
          ),
        ),
      );
    }
    final profile = ref.watch(profileProvider);
    if (boot.isLoading || profile.isLoading) return const _Splash();
    if (profile.value == null) return const OnboardingScreen();
    return child;
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.appName, style: context.text.headlineMedium),
            const SizedBox(height: Gap.lg),
            const SizedBox(width: 160, child: LinearProgressIndicator()),
            const SizedBox(height: Gap.md),
            Text(
              S.preparingFoods,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: S.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: S.diary,
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: S.plan,
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: S.evolution,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: S.profile,
          ),
        ],
      ),
    );
  }
}
