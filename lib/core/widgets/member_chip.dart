import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Pill with a colored initial bubble + name (DESIGN.md member split badge).
class MemberChip extends StatelessWidget {
  const MemberChip({super.key, required this.id, required this.name, this.trailing});

  final String id;
  final String name;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.memberColor(id);
    final text = Theme.of(context).textTheme;
    return Container(
      height: 28,
      padding: const EdgeInsetsDirectional.only(start: 4, end: 10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: color,
          child: Text(name.characters.first.toUpperCase(),
              style: text.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 6),
        Text(name, style: text.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          Text(trailing!, style: text.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ]),
    );
  }
}
