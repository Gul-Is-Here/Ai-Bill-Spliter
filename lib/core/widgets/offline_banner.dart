import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_spacing.dart';
import '../services/connectivity_service.dart';

/// Wraps the whole app; shows a banner while offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();
    return Column(
      children: [
        Expanded(child: child),
        Obx(() => AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: connectivity.isOnline.value
                  ? const SizedBox(width: double.infinity)
                  : Material(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: SafeArea(
                        top: false,
                        child: Semantics(
                          liveRegion: true,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Text('offline_banner'.tr, textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    ),
            )),
      ],
    );
  }
}
