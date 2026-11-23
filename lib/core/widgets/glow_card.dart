import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../constants/app_spacing.dart';

/// Bento hero card with soft teal/cyan ambient glows in opposite corners.
class GlowCard extends StatelessWidget {
  const GlowCard({super.key, required this.child, this.padding = const EdgeInsets.all(AppSpacing.md)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scheme.surfaceContainerLowest, scheme.surfaceContainerLow],
        ),
        boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Stack(children: [
        const Positioned(top: -40, right: -40, child: _Glow(AppColors.accentCyan)),
        const Positioned(bottom: -40, left: -40, child: _Glow(AppColors.brand)),
        Padding(padding: padding, child: child),
      ]),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: 176,
          height: 176,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)]),
          ),
        ),
      );
}
