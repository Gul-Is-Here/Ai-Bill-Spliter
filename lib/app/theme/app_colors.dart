import 'package:flutter/material.dart';

/// SplitSnap AI design tokens (DESIGN.md).
abstract class AppColors {
  // Material 3 roles (light)
  static const primary = Color(0xFF006B56);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF00C49F);
  static const onPrimaryContainer = Color(0xFF004B3B);
  static const secondary = Color(0xFF006B5F);
  static const secondaryContainer = Color(0xFF8DF5E4);
  static const onSecondaryContainer = Color(0xFF007165);
  static const tertiary = Color(0xFF00687A);
  static const tertiaryContainer = Color(0xFF20BDDB);
  static const onTertiaryContainer = Color(0xFF004855);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
  static const surface = Color(0xFFF8F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const surfaceContainerHigh = Color(0xFFDCE9FF);
  static const surfaceContainerHighest = Color(0xFFD3E4FE);
  static const onSurface = Color(0xFF0B1C30);
  static const onSurfaceVariant = Color(0xFF3C4A44);
  static const outline = Color(0xFF6C7A74);
  static const outlineVariant = Color(0xFFBBCAC3);
  static const inverseSurface = Color(0xFF213145);
  static const inversePrimary = Color(0xFF3FDEB7);

  // Brand extras
  static const brand = Color(0xFF00C49F); // electric emerald-teal
  static const brandDeep = Color(0xFF00897B);
  static const cyan = Color(0xFF06B6D4);
  static const accentMint = Color(0xFFA7F3D0);
  static const accentCyan = Color(0xFF22D3EE);
  static const canvas = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const dark = Color(0xFF0F172A);
  static const slate = Color(0xFF64748B);
  static const inputFill = Color(0xFFF1F5F9);
  static const hairline = Color(0x0F0F172A); // rgba(15,23,42,0.06)

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand, brandDeep],
  );

  /// Member attribution palette; pick with [memberColor].
  static const members = [
    Color(0xFF00C49F), // teal
    Color(0xFFF59E0B), // amber
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // magenta
    Color(0xFF0284C7), // sky
  ];

  /// Stable color per participant id.
  static Color memberColor(String id) => members[id.hashCode.abs() % members.length];

  // Dark scheme surfaces (slate foundation)
  static const darkSurface = Color(0xFF0F172A);
  static const darkSurfaceContainer = Color(0xFF1E293B);
  static const darkSurfaceContainerHigh = Color(0xFF273449);
  static const darkOnSurface = Color(0xFFE2E8F0);
}
