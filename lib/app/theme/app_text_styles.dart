
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Outfit for headlines & money, Plus Jakarta Sans for body/labels (DESIGN.md typography).
/// Urdu glyphs fall back to the system font automatically.
abstract class AppTextStyles {
  static const _tnum = [FontFeature.tabularFigures()];

  static TextStyle _outfit(double size, FontWeight weight, double height, double tracking) => GoogleFonts.outfit(
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: tracking * size,
        fontFeatures: _tnum,
      );

  static TextStyle _jakarta(double size, FontWeight weight, double height, [double tracking = 0]) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: tracking * size,
        fontFeatures: _tnum,
      );

  static final displayLg = _outfit(30, FontWeight.w700, 36, -0.025); // mobile size
  static final headlineLg = _outfit(26, FontWeight.w700, 32, -0.02);
  static final headlineMd = _outfit(20, FontWeight.w600, 26, -0.015);
  static final headlineSm = _outfit(17, FontWeight.w600, 22, -0.01);
  static final currencyDisplay = _outfit(28, FontWeight.w700, 32, -0.02);
  static final currencyItem = _outfit(18, FontWeight.w600, 24, -0.01);

  static final bodyLg = _jakarta(16, FontWeight.w400, 24);
  static final bodyMd = _jakarta(14, FontWeight.w400, 20);
  static final bodySm = _jakarta(12, FontWeight.w400, 16);
  static final labelLg = _jakarta(14, FontWeight.w600, 18, 0.01);
  static final labelMd = _jakarta(12, FontWeight.w600, 16, 0.015);
  static final labelCaps = _jakarta(10, FontWeight.w700, 14, 0.06);

  static TextTheme textTheme(Color onSurface, Color muted) => TextTheme(
        displayLarge: displayLg.copyWith(color: onSurface),
        displayMedium: currencyDisplay.copyWith(color: onSurface),
        displaySmall: currencyDisplay.copyWith(color: onSurface),
        headlineLarge: headlineLg.copyWith(color: onSurface),
        headlineMedium: headlineLg.copyWith(color: onSurface),
        headlineSmall: headlineMd.copyWith(color: onSurface),
        titleLarge: headlineMd.copyWith(color: onSurface),
        titleMedium: headlineSm.copyWith(color: onSurface),
        titleSmall: currencyItem.copyWith(fontSize: 15, color: onSurface),
        bodyLarge: bodyLg.copyWith(color: onSurface),
        bodyMedium: bodyMd.copyWith(color: onSurface),
        bodySmall: bodySm.copyWith(color: muted),
        labelLarge: labelLg.copyWith(color: onSurface),
        labelMedium: labelMd.copyWith(color: muted),
        labelSmall: labelCaps.copyWith(color: muted),
      );
}
