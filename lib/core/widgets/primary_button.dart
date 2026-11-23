import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../constants/app_spacing.dart';

/// Primary CTA: 52px, emerald gradient, 16px radius, presses down to 98%.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.isLoading = false});

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final radius = BorderRadius.circular(AppSpacing.radius);
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: enabled || widget.isLoading ? 1 : 0.5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(color: AppColors.brand.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: radius,
                onTap: enabled ? widget.onPressed : null,
                onHighlightChanged: (v) => setState(() => _pressed = v),
                child: SizedBox(
                  height: AppSpacing.buttonHeight,
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(
                            widget.label,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 15),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
