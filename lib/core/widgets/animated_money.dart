import 'package:flutter/material.dart';

import '../utils/money.dart';

/// Counts smoothly between values when a total changes.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney({super.key, required this.minor, required this.currency, this.style});

  final int minor;
  final String currency;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: minor.toDouble()),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text(Money.format(value.round(), currency), style: style),
    );
  }
}
