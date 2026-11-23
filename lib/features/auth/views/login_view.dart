import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/view_state.dart';
import '../../onboarding/widgets/onboarding_heroes.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/email_auth_form.dart';

class LoginView extends GetView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Obx(() {
                final loading = controller.state.value == ViewState.loading;
                final emailMode = controller.showEmailForm.value;
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // Brand header
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.receipt_long, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Text('app_name'.tr, style: text.titleMedium),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: emailMode ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: const ScanHero(),
                    secondChild: const SizedBox(width: double.infinity),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('welcome_title'.tr, textAlign: TextAlign.center, style: text.displayMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text('welcome_body'.tr,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.5)),
                  const SizedBox(height: AppSpacing.lg),
                  _GoogleButton(onPressed: loading ? null : controller.signInWithGoogle),
                  const SizedBox(height: AppSpacing.gutter),
                  if (emailMode)
                    const EmailAuthForm()
                  else
                    OutlinedButton.icon(
                      onPressed: loading ? null : controller.openEmailForm,
                      icon: const Icon(Icons.mail_outline, size: 20),
                      label: Text('continue_with_email'.tr),
                    ),
                  if (!emailMode && controller.errorMessage.value != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Semantics(
                      liveRegion: true,
                      child: Text(controller.errorMessage.value!,
                          textAlign: TextAlign.center, style: TextStyle(color: scheme.error)),
                    ),
                  ],
                  if (loading && !emailMode) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(99)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.lock_outline, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Flexible(child: Text('privacy_badge'.tr, style: text.labelSmall)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gutter),
                  const _LegalLine(),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.dark.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        onTap: onPressed,
        child: SizedBox(
          height: AppSpacing.buttonHeight,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const _GoogleG(),
            const SizedBox(width: 12),
            Flexible(
              child: Text('continue_with_google'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSurface, fontSize: 15)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Four-color Google "G" drawn with arcs (no image asset needed).
class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) => const SizedBox.square(dimension: 20, child: CustomPaint(painter: _GPainter()));
}

class _GPainter extends CustomPainter {
  const _GPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.2;
    final rect = Offset(stroke / 2, stroke / 2) & Size(size.width - stroke, size.height - stroke);
    Paint p(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    const deg = 3.14159265 / 180;
    canvas.drawArc(rect, -40 * deg, -100 * deg, false, p(const Color(0xFFEA4335))); // red, top
    canvas.drawArc(rect, -140 * deg, -90 * deg, false, p(const Color(0xFFFBBC05))); // yellow, left
    canvas.drawArc(rect, 130 * deg, -100 * deg, false, p(const Color(0xFF34A853))); // green, bottom
    canvas.drawArc(rect, 30 * deg, -30 * deg, false, p(const Color(0xFF4285F4))); // blue, right
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2, size.height / 2 - stroke / 2, size.width / 2, stroke),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegalLine extends StatelessWidget {
  const _LegalLine();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final link = text.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700);
    return Text.rich(
      TextSpan(style: text.bodySmall, children: [
        TextSpan(text: '${'agree_prefix'.tr} '),
        TextSpan(
          text: 'terms'.tr,
          style: link,
          recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(AppRoutes.legal, arguments: 'terms'),
        ),
        TextSpan(text: ' ${'and'.tr} '),
        TextSpan(
          text: 'privacy_policy'.tr,
          style: link,
          recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(AppRoutes.legal, arguments: 'privacy'),
        ),
        TextSpan(text: 'agree_suffix'.tr),
      ]),
      textAlign: TextAlign.center,
    );
  }
}
