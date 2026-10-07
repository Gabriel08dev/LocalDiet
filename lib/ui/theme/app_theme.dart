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

/// Raios de canto. O app é todo arredondado: cartões largos, botões e
/// etiquetas em forma de pílula.
abstract final class Corner {
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 28;
  static const double xl = 36;
}

/// Uma cor pastel de fundo com a cor de traço que funciona sobre ela.
class Tone {
  const Tone(this.background, this.foreground);

  final Color background;
  final Color foreground;

  static Tone lerp(Tone a, Tone b, double t) => Tone(
    Color.lerp(a.background, b.background, t)!,
    Color.lerp(a.foreground, b.foreground, t)!,
  );
}

/// Cores que o Material não define.
///
/// Todo o visual passa por aqui e pelo [ColorScheme]; um redesign troca estes
/// valores sem tocar nas telas.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.protein,
    required this.carb,
    required this.fat,
    required this.over,
    required this.hero,
    required this.onHero,
    required this.heroOver,
    required this.peach,
    required this.mint,
    required this.pink,
    required this.lavender,
    required this.sky,
    required this.lemon,
    required this.glow,
  });

  final Color protein;
  final Color carb;
  final Color fat;

  /// Consumo acima da meta, sobre as superfícies comuns.
  final Color over;

  /// As cores do degradê do cartão de destaque, do canto superior esquerdo
  /// ao inferior direito.
  final List<Color> hero;

  /// Texto e traços sobre o cartão de destaque.
  final Color onHero;

  /// Consumo acima da meta, sobre o cartão de destaque.
  final Color heroOver;

  // Tons pastel para ícones e etiquetas.
  final Tone peach;
  final Tone mint;
  final Tone pink;
  final Tone lavender;
  final Tone sky;
  final Tone lemon;

  /// Cor da sombra suave sob os elementos flutuantes.
  final Color glow;

  static const light = AppColors(
    protein: Color(0xFF6C7BF2),
    carb: Color(0xFFF2A65A),
    fat: Color(0xFFEC7FB0),
    over: Color(0xFFD03058),
    hero: [Color(0xFFD9D2FF), Color(0xFFCDE7FF), Color(0xFFCFF5E4)],
    onHero: Color(0xFF1B1740),
    heroOver: Color(0xFFC02650),
    peach: Tone(Color(0xFFFFE4D2), Color(0xFF9A4A17)),
    mint: Tone(Color(0xFFD6F5E7), Color(0xFF14694A)),
    pink: Tone(Color(0xFFFFDDEA), Color(0xFF9B2C5C)),
    lavender: Tone(Color(0xFFE7E2FF), Color(0xFF4334B8)),
    sky: Tone(Color(0xFFDCEEFF), Color(0xFF1D5C99)),
    lemon: Tone(Color(0xFFFFF2C7), Color(0xFF7A5B00)),
    glow: Color(0x245B4BDB),
  );

  static const dark = AppColors(
    protein: Color(0xFFA9B4FF),
    carb: Color(0xFFFFC78A),
    fat: Color(0xFFFFA9CF),
    over: Color(0xFFFF9DB2),
    hero: [Color(0xFF3A2F8F), Color(0xFF244F86), Color(0xFF1F6B5C)],
    onHero: Color(0xFFF4F2FF),
    heroOver: Color(0xFFFFC2CF),
    peach: Tone(Color(0xFF4A2A16), Color(0xFFFFC9A6)),
    mint: Tone(Color(0xFF153F31), Color(0xFFA8F0D1)),
    pink: Tone(Color(0xFF4A1D32), Color(0xFFFFB8D4)),
    lavender: Tone(Color(0xFF2C2565), Color(0xFFCFC6FF)),
    sky: Tone(Color(0xFF17344F), Color(0xFFB5DBFF)),
    lemon: Tone(Color(0xFF40340A), Color(0xFFFFE28A)),
    glow: Color(0x40000000),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      protein: Color.lerp(protein, other.protein, t)!,
      carb: Color.lerp(carb, other.carb, t)!,
      fat: Color.lerp(fat, other.fat, t)!,
      over: Color.lerp(over, other.over, t)!,
      hero: [
        for (var index = 0; index < hero.length; index++)
          Color.lerp(hero[index], other.hero[index], t)!,
      ],
      onHero: Color.lerp(onHero, other.onHero, t)!,
      heroOver: Color.lerp(heroOver, other.heroOver, t)!,
      peach: Tone.lerp(peach, other.peach, t),
      mint: Tone.lerp(mint, other.mint, t),
      pink: Tone.lerp(pink, other.pink, t),
      lavender: Tone.lerp(lavender, other.lavender, t),
      sky: Tone.lerp(sky, other.sky, t),
      lemon: Tone.lerp(lemon, other.lemon, t),
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

/// Botão mais baixo, para ações dentro de listas e cartões.
final compactButton = ButtonStyle(
  minimumSize: const WidgetStatePropertyAll(Size(48, 40)),
  padding: const WidgetStatePropertyAll(
    EdgeInsets.symmetric(horizontal: Gap.lg),
  ),
  tapTargetSize: MaterialTapTargetSize.padded,
  visualDensity: VisualDensity.compact,
);

// Fundo lilás muito claro, cartões brancos e o violeta reservado para ações.
// As demais cores são pastéis, usadas em ícones, etiquetas e no cartão de
// destaque. No tema escuro, fundo azul-noite e os pastéis como luz.
const _light = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF5B4BDB),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFE7E2FF),
  onPrimaryContainer: Color(0xFF2A1F7A),
  secondary: Color(0xFF2C8A66),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD6F5E7),
  onSecondaryContainer: Color(0xFF0F4A30),
  tertiary: Color(0xFF2B6CB0),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFDCEEFF),
  onTertiaryContainer: Color(0xFF123A66),
  error: Color(0xFFC62B4F),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFE1E8),
  onErrorContainer: Color(0xFF7A1230),
  surface: Color(0xFFF5F4FB),
  onSurface: Color(0xFF17152B),
  onSurfaceVariant: Color(0xFF625F7A),
  outline: Color(0xFFC4C0DA),
  outlineVariant: Color(0xFFEAE7F6),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFFFFFFF),
  surfaceContainer: Color(0xFFFFFFFF),
  surfaceContainerHigh: Color(0xFFF1EFFA),
  surfaceContainerHighest: Color(0xFFE8E5F5),
  inverseSurface: Color(0xFF211F38),
  onInverseSurface: Color(0xFFF3F1FF),
  inversePrimary: Color(0xFFC3B9FF),
  surfaceTint: Color(0x00000000),
);

const _dark = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFB3A6FF),
  onPrimary: Color(0xFF1C1552),
  primaryContainer: Color(0xFF2C2565),
  onPrimaryContainer: Color(0xFFE3DEFF),
  secondary: Color(0xFFA8F0D1),
  onSecondary: Color(0xFF0B3A28),
  secondaryContainer: Color(0xFF173F33),
  onSecondaryContainer: Color(0xFFBFF2DC),
  tertiary: Color(0xFFB5DBFF),
  onTertiary: Color(0xFF0E3152),
  tertiaryContainer: Color(0xFF17344F),
  onTertiaryContainer: Color(0xFFCFE6FF),
  error: Color(0xFFFF9DB2),
  onError: Color(0xFF5A0F25),
  errorContainer: Color(0xFF4A1826),
  onErrorContainer: Color(0xFFFFD9E1),
  surface: Color(0xFF0E0D1A),
  onSurface: Color(0xFFECEBFA),
  onSurfaceVariant: Color(0xFFA6A3C2),
  outline: Color(0xFF4A4770),
  outlineVariant: Color(0xFF262447),
  surfaceContainerLowest: Color(0xFF181729),
  surfaceContainerLow: Color(0xFF181729),
  surfaceContainer: Color(0xFF181729),
  surfaceContainerHigh: Color(0xFF211F38),
  surfaceContainerHighest: Color(0xFF2C2A48),
  inverseSurface: Color(0xFFECEBFA),
  onInverseSurface: Color(0xFF211F38),
  inversePrimary: Color(0xFF5B4BDB),
  surfaceTint: Color(0x00000000),
);

ThemeData buildTheme(Brightness brightness) {
  final scheme = brightness == Brightness.dark ? _dark : _light;
  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: brightness,
  );
  final text = base.textTheme;
  final hairline = BorderSide(color: scheme.outlineVariant);

  OutlineInputBorder inputBorder(BorderSide side) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(Corner.md),
    borderSide: side,
  );
  // Os estilos de texto dos componentes partem da tipografia do tema, para
  // herdar a família da fonte.
  final buttonText = text.labelLarge?.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    extensions: [
      brightness == Brightness.dark ? AppColors.dark : AppColors.light,
    ],
    textTheme: text.copyWith(
      displaySmall: text.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      headlineMedium: text.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: text.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
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
        side: hairline,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: inputBorder(hairline),
      enabledBorder: inputBorder(hairline),
      focusedBorder: inputBorder(BorderSide(color: scheme.primary, width: 1.6)),
      errorBorder: inputBorder(BorderSide(color: scheme.error)),
      focusedErrorBorder: inputBorder(
        BorderSide(color: scheme.error, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Gap.xl - 4,
        vertical: Gap.lg,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 54),
        shape: const StadiumBorder(),
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 54),
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outline),
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: const StadiumBorder(),
        textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: hairline,
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: scheme.primaryContainer,
      showCheckmark: false,
      labelStyle: text.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 6),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStatePropertyAll(hairline),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primaryContainer
              : scheme.surfaceContainerLow,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Corner.xl)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corner.xl),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corner.md),
        side: hairline,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: scheme.primaryContainer,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => text.labelMedium?.copyWith(
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? scheme.onSurface
              : scheme.onSurfaceVariant,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.onPrimaryContainer
              : scheme.onSurfaceVariant,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      shape: const StadiumBorder(),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corner.md),
      ),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: Gap.lg),
      minVerticalPadding: Gap.sm,
    ),
  );
}
