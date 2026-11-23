import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/glow_card.dart';
import '../../../core/widgets/member_chip.dart';

/// Illustrations for the three onboarding steps. Amounts are an example, formatted in PKR.
const _c = 'PKR';

/// Step 1: tilted receipt being scanned + "equal split" card + settled pill.
class ScanHero extends StatelessWidget {
  const ScanHero({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return GlowCard(
      child: SizedBox(
        height: 230,
        child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
          Transform.rotate(
            angle: 6 * math.pi / 180,
            child: Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accentCyan]),
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                boxShadow: [BoxShadow(color: AppColors.brand.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: scheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                    const Spacer(),
                    Flexible(child: _Tag('ai_scan'.tr)),
                  ]),
                  const SizedBox(height: 10),
                  for (final w in const [0.75, 0.5, 0.85]) _Bar(w),
                  const Spacer(),
                  Row(children: [
                    Flexible(child: Text('total'.tr.toUpperCase(), style: text.labelSmall, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(Money.format(240000, _c), style: text.titleMedium?.copyWith(color: AppColors.primary)),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
          PositionedDirectional(
            start: 4,
            top: 28,
            child: Transform.rotate(
              angle: -12 * math.pi / 180,
              child: Container(
                width: 112,
                height: 112,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.brandDeep,
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('instant'.tr.toUpperCase(),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: text.labelSmall?.copyWith(color: AppColors.accentMint)),
                    ),
                  ]),
                  const Spacer(),
                  Text('method_equal'.tr, style: text.labelSmall?.copyWith(color: AppColors.accentMint)),
                  FittedBox(
                    child: Text('${Money.format(80000, _c)} ${'per_person'.tr}',
                        style: text.titleMedium?.copyWith(color: Colors.white)),
                  ),
                ]),
              ),
            ),
          ),
          PositionedDirectional(
            end: 0,
            bottom: 0,
            child: _Pill(children: [
              const _AvatarStack(['a', 'r', 's'], ['A', 'R', 'S']),
              const SizedBox(width: 8),
              Text('settled'.tr, style: text.labelMedium?.copyWith(color: scheme.onSurface)),
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, size: 16, color: AppColors.brand),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Step 2: item bento cards with member chips + share-to-WhatsApp preview.
class SplitHero extends StatelessWidget {
  const SplitHero({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GlowCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.auto_awesome, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('ai_split_active'.tr, style: text.labelMedium?.copyWith(color: AppColors.primary)),
            ]),
          ),
        ]),
        const SizedBox(height: AppSpacing.gutter),
        _ItemCard(
          icon: Icons.local_pizza_outlined,
          name: 'demo_item_pizza'.tr,
          detail: 'shared_ways'.trParams({'n': '3'}),
          totalMinor: 255000,
          each: 85000,
          members: const [('a', 'Ali'), ('s', 'Sara'), ('y', '')],
        ),
        const SizedBox(height: 10),
        _ItemCard(
          icon: Icons.local_cafe_outlined,
          name: 'demo_item_drinks'.tr,
          detail: 'people_count'.trParams({'count': '2'}),
          totalMinor: 92000,
          each: 46000,
          members: const [('d', 'Danish'), ('e', 'Eman')],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            const CircleAvatar(radius: 14, backgroundColor: Color(0xFF25D366), child: Icon(Icons.chat, size: 15, color: Colors.white)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'demo_share_message'.trParams({'amount': Money.format(85000, _c), 'name': 'Ali'}),
                style: text.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// Step 3: group balances and the minimal payments to settle.
class SettleHero extends StatelessWidget {
  const SettleHero({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    Widget transfer(String fromId, String from, String toId, String to, int amount) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          child: Row(children: [
            Expanded(
              flex: 3,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Row(children: [
                  MemberChip(id: fromId, name: from),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_forward, size: 18, color: AppColors.slate),
                  ),
                  MemberChip(id: toId, name: to),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(Money.format(amount, _c), style: text.titleSmall),
              ),
            ),
          ]),
        );

    return GlowCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.flight_takeoff, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text('demo_group_name'.tr, style: text.titleMedium)),
          Text('people_count'.trParams({'count': '4'}), style: text.bodySmall),
        ]),
        const SizedBox(height: AppSpacing.gutter),
        transfer('r', 'Rizwan', 'a', 'Ali', 420000),
        transfer('s', 'Sara', 'a', 'Ali', 185000),
        transfer('d', 'Danish', 'e', 'Eman', 60000),
        const SizedBox(height: 4),
        Center(
          child: _Pill(children: [
            const Icon(Icons.bolt, size: 16, color: AppColors.warning),
            const SizedBox(width: 4),
            Text('fewest_payments'.trParams({'n': '3'}), style: text.labelMedium?.copyWith(color: scheme.onSurface)),
          ]),
        ),
      ]),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.icon,
    required this.name,
    required this.detail,
    required this.totalMinor,
    required this.each,
    required this.members,
  });

  final IconData icon;
  final String name;
  final String detail;
  final int totalMinor;
  final int each;
  final List<(String, String)> members;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(detail, style: text.bodySmall),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(Money.format(totalMinor, _c), style: text.titleSmall),
            Text('${Money.format(each, _c)} ${'per_person'.tr}',
                style: text.labelSmall?.copyWith(color: AppColors.primary)),
          ]),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final (id, name) in members) MemberChip(id: id, name: name.isEmpty ? 'me'.tr : name),
        ]),
      ]),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: AppColors.accentMint, borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary)),
      );
}

class _Bar extends StatelessWidget {
  const _Bar(this.widthFactor);
  final double widthFactor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(99),
          boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, children: children)),
        ),
      );
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack(this.ids, this.initials);
  final List<String> ids;
  final List<String> initials;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 12.0 + 18 * ids.length,
        height: 24,
        child: Stack(children: [
          for (var i = 0; i < ids.length; i++)
            PositionedDirectional(
              start: i * 18.0,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.memberColor(ids[i]),
                  child: Text(initials[i],
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
        ]),
      );
}
