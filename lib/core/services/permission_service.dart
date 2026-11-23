import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// Shows a rationale before the system prompt, and a settings link when permanently denied.
class PermissionService {
  static final _rationaleKeys = {
    Permission.camera: 'perm_camera_rationale',
    Permission.microphone: 'perm_microphone_rationale',
  };

  Future<bool> ensure(Permission permission) async {
    var status = await permission.status;
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      final open = await _dialog('perm_denied_body'.tr, 'open_settings'.tr);
      if (open) await openAppSettings();
      return false;
    }

    final proceed = await _dialog(_rationaleKeys[permission]!.tr, 'continue'.tr);
    if (!proceed) return false;
    status = await permission.request();
    return status.isGranted || status.isLimited;
  }

  Future<bool> _dialog(String body, String confirm) async {
    final result = await Get.dialog<bool>(AlertDialog(
      title: Text('perm_title'.tr),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('not_now'.tr)),
        FilledButton(onPressed: () => Get.back(result: true), child: Text(confirm)),
      ],
    ));
    return result ?? false;
  }
}
