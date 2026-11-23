import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static final light = _build(_lightScheme);
  static final dark = _build(_darkScheme);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.canvas,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: Color(0xFFEAF1FF),
    inversePrimary: AppColors.inversePrimary,
    surfaceTint: AppColors.primary,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.inversePrimary,
    onPrimary: Color(0xFF00382B),
    primaryContainer: AppColors.brandDeep,
    onPrimaryContainer: AppColors.accentMint,
    secondary: Color(0xFF70D8C8),
    onSecondary: Color(0xFF003731),
    secondaryContainer: Color(0xFF005048),
    onSecondaryContainer: AppColors.secondaryContainer,
    tertiary: AppColors.accentCyan,
    onTertiary: Color(0xFF00363F),
    tertiaryContainer: Color(0xFF004E5C),
    onTertiaryContainer: Color(0xFFACEDFF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: AppColors.errorContainer,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    onSurfaceVariant: Color(0xFF94A3B8),
    surfaceContainerLowest: Color(0xFF0B1222),
    surfaceContainerLow: Color(0xFF162033),
    surfaceContainer: AppColors.darkSurfaceContainer,
    surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
    surfaceContainerHighest: Color(0xFF334155),
    outline: Color(0xFF64748B),
    outlineVariant: Color(0xFF334155),
    inverseSurface: AppColors.darkOnSurface,
    onInverseSurface: AppColors.darkSurface,
    inversePrimary: AppColors.primary,
    surfaceTint: AppColors.inversePrimary,
  );

  static ThemeData _build(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final text = AppTextStyles.textTheme(scheme.onSurface, isDark ? scheme.onSurfaceVariant : AppColors.slate);
    final r16 = BorderRadius.circular(AppSpacing.radius);
    final r14 = BorderRadius.circular(AppSpacing.radiusInput);
    final cardColor = isDark ? scheme.surfaceContainer : AppColors.card;
    final hairline = isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.hairline;
    const buttonSize = Size(AppSpacing.minTapTarget, AppSpacing.buttonHeight);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: text.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: BorderSide(color: hairline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          backgroundColor: isDark ? scheme.primary : AppColors.brandDeep,
          foregroundColor: isDark ? scheme.onPrimary : Colors.white,
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: r16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        // "Secondary frosted" button.
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          backgroundColor: AppColors.brand.withValues(alpha: 0.08),
          foregroundColor: isDark ? scheme.primary : AppColors.brandDeep,
          side: BorderSide(color: AppColors.brandDeep.withValues(alpha: 0.2)),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: r16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSpacing.minTapTarget, AppSpacing.minTapTarget),
          foregroundColor: isDark ? scheme.primary : AppColors.brandDeep,
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: r16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        elevation: 6,
        extendedTextStyle: text.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusCard)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainer : AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        hintStyle: text.bodyMedium?.copyWith(color: AppColors.slate),
        labelStyle: text.bodyMedium?.copyWith(color: isDark ? scheme.onSurfaceVariant : AppColors.slate),
        border: OutlineInputBorder(borderRadius: r14, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: r14, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: r14,
          borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(borderRadius: r14, borderSide: BorderSide(color: scheme.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: r14, borderSide: BorderSide(color: scheme.error, width: 1.5)),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: hairline),
        backgroundColor: cardColor,
        selectedColor: AppColors.brand.withValues(alpha: 0.14),
        checkmarkColor: isDark ? scheme.primary : AppColors.brandDeep,
        labelStyle: text.labelMd(scheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.brand.withValues(alpha: 0.14),
          selectedForegroundColor: isDark ? scheme.primary : AppColors.brandDeep,
          textStyle: text.labelLarge,
          side: BorderSide(color: hairline),
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: AppColors.brand,
        inactiveTrackColor: isDark ? scheme.surfaceContainerHighest : const Color(0xFFE2E8F0),
        thumbColor: AppColors.brand,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayColor: AppColors.brand.withValues(alpha: 0.15),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: const BorderSide(color: AppColors.slate, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.brand : null),
      ),
      navigationBarTheme: NavigationBarThemeData(
        // Dark dock with mint active icons.
        backgroundColor: AppColors.dark,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.accentMint.withValues(alpha: 0.14),
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              color: s.contains(WidgetState.selected) ? AppColors.accentMint : const Color(0xFF94A3B8),
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => text.labelMedium?.copyWith(
              color: s.contains(WidgetState.selected) ? AppColors.accentMint : const Color(0xFF94A3B8),
            )),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? scheme.surfaceContainer : AppColors.card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? scheme.surfaceContainer : AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.lg)),
        titleTextStyle: text.headlineSmall,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: text.bodySmall,
        iconColor: scheme.onSurfaceVariant,
      ),
      dividerTheme: DividerThemeData(color: hairline, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.dark,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: r16),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.brand),
    );
  }
}

extension on TextTheme {
  TextStyle? labelMd(Color color) => labelMedium?.copyWith(color: color);
}
