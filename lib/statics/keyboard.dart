import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/responsive_service.dart';

class Keyboard {
  static RxBool visible = ResponsiveService().keyboardVisible;
  static bool get isVisible => visible.value;
  static bool closable = true;

  static Future<void> close() async {
    if (!isVisible || !closable) {
      closable = true;
      return;
    }
    removeFocus();
    await closed();
  }

  static void removeFocus() {
    final currentFocus = FocusScope.of(Get.context!);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  static Future<void> closed() async {
    while (isVisible) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}
