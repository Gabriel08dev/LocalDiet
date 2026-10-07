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
import 'widgets/motion.dart';

/// Rota de tela cheia, com a transição de entrada do app.
GoRoute _screen(
  String path,
  Widget Function(BuildContext context, GoRouterState state) builder,
) => GoRoute(
  path: path,
  pageBuilder: (context, state) => risePage(state, builder(context, state)),
);

final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute(
        builder: (context, state, shell) =>
            _AppGate(child: _Shell(shell: shell)),
        // As abas trocam com uma entrada animada, em vez do corte seco.
        navigatorContainerBuilder: (context, shell, children) =>
            BranchSwitcher(index: shell.currentIndex, children: children),
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
      _screen('/add', (context, state) {
        final query = state.uri.queryParameters;
        return MealBuilderScreen(
          target: query['target'] == 'plan' ? AddTarget.plan : AddTarget.diary,
          meal: MealType.values.firstWhere(
            (meal) => meal.name == query['meal'],
            orElse: () => MealType.other,
          ),
          date:
              LocalDate.tryParse(query['date'] ?? '') ??
              ref.read(todayProvider),
        );
      }),
      _screen(
        '/food/new',
        (context, state) =>
            CustomFoodScreen(initialName: state.uri.queryParameters['name']),
      ),
      _screen(
        '/food/edit/:id',
        (context, state) =>
            CustomFoodScreen(foodId: state.pathParameters['id']),
      ),
      _screen(
        '/food/view/:id',
        (context, state) =>
            FoodDetailScreen(foodId: state.pathParameters['id']!),
      ),
      _screen('/my-foods', (context, state) => const MyFoodsScreen()),
      _screen('/profile/edit', (context, state) => const EditProfileScreen()),
      _screen('/data', (context, state) => const DataScreen()),
      _screen('/about', (context, state) => const AboutScreen()),
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
    final profile = ref.watch(profileProvider);
    final Widget current;
    if (boot.hasError) {
      current = Scaffold(
        key: const ValueKey('erro'),
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
    } else if (boot.isLoading || profile.isLoading) {
      current = const _Splash(key: ValueKey('abertura'));
    } else if (profile.value == null) {
      current = const OnboardingScreen(key: ValueKey('onboarding'));
    } else {
      current = KeyedSubtree(key: const ValueKey('app'), child: child);
    }
    // A passagem da abertura para o onboarding e para o app é esmaecida.
    return AnimatedSwitcher(
      duration: Motion.of(context, Motion.base),
      child: current,
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 76),
            const SizedBox(height: Gap.lg),
            Text(S.appName, style: context.text.headlineMedium),
            const SizedBox(height: Gap.xl),
            SizedBox(
              width: 160,
              child: ProgressLine(
                value: null,
                color: context.colors.primary,
                height: 4,
              ),
            ),
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

/// A moldura das abas: o conteúdo e a barra de navegação flutuante.
class _Shell extends StatelessWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: shell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(Corner.xl),
            border: Border.all(color: colors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: context.appColors.glow,
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Corner.xl),
            child: NavigationBar(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: (index) => shell.goBranch(
                index,
                initialLocation: index == shell.currentIndex,
              ),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: S.home,
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: S.diary,
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_note_outlined),
                  selectedIcon: Icon(Icons.event_note_rounded),
                  label: S.plan,
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights_rounded),
                  label: S.evolution,
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: S.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
