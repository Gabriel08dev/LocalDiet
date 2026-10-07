import 'package:flutter/material.dart';

/// Espaçamentos do app, em múltiplos de 4.
abstract final class Gap {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Raios de canto.
abstract final class Corner {
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
}

/// Cores que o Material não define: uma por macronutriente e a de excedente.
///
/// Todo o visual passa por aqui e pelo [ColorScheme]; um redesign troca estes
/// valores sem tocar nas telas.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.protein,
    required this.carb,
    required this.fat,
    required this.over,
  });

  final Color protein;
  final Color carb;
  final Color fat;

  /// Consumo acima da meta.
  final Color over;

  static const light = AppColors(
    protein: Color(0xFF2F6FD6),
    carb: Color(0xFFB86E00),
    fat: Color(0xFFA2409A),
    over: Color(0xFFB3261E),
  );

  static const dark = AppColors(
    protein: Color(0xFF8FB8FF),
    carb: Color(0xFFFFB95C),
    fat: Color(0xFFF0A3E6),
    over: Color(0xFFFFB4AB),
  );

  @override
  AppColors copyWith({Color? protein, Color? carb, Color? fat, Color? over}) =>
      AppColors(
        protein: protein ?? this.protein,
        carb: carb ?? this.carb,
        fat: fat ?? this.fat,
        over: over ?? this.over,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      protein: Color.lerp(protein, other.protein, t)!,
      carb: Color.lerp(carb, other.carb, t)!,
      fat: Color.lerp(fat, other.fat, t)!,
      over: Color.lerp(over, other.over, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

const _seed = Color(0xFF1F8A5B);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: brightness,
  );
  final text = base.textTheme;
  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    extensions: [
      brightness == Brightness.dark ? AppColors.dark : AppColors.light,
    ],
    textTheme: text.copyWith(
      headlineMedium: text.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corner.lg),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Corner.md),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Gap.lg,
        vertical: Gap.md,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corner.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corner.md),
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Corner.lg)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      height: 68,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.5),
      space: 1,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: Gap.lg),
      minVerticalPadding: Gap.sm,
    ),
  );
}
