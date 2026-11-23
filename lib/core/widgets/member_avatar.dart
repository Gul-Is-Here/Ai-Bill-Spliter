import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Circle avatar tinted with the member's attribution color (12% fill, saturated initial).
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.id, required this.name, this.radius = 20});

  final String id;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.memberColor(id);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.12),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
