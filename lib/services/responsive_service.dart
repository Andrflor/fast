import 'dart:math';

import 'package:fast/services/scaffold_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../statics/keyboard.dart';
import '../statics/menu.dart';
import '../statics/platform.dart';
import '../statics/screen.dart';

class ResponsiveService {
  bool get isKeyboardVisible => keyboardVisible.value;

  Size get size => sizeObs.value;
  double get width => size.width;
  double get height => size.height;

  factory ResponsiveService() => _instance ??= ResponsiveService._();

  ResponsiveService._();

  static ResponsiveService? _instance;

  static bool get willDisplayLarge =>
      Screen.width > 1000 && Screen.height > 500 && Screen.isLarge;

  static bool get willDisplayCollapsed =>
      Screen.width > 600 && Screen.height > 350 && Screen.isLarge;
  final sizeObs = const Size(0, 0).obs;
  final diagonalInches = 0.0.obs;

  final keyboardVisible = false.obs;
  final menuWidth = 0.0.obs;
  final displayMenu = false.obs;
  final orientation = Orientation.portrait.obs;
  final menuAnimating = false.obs;

  void screenChanged() {
    if (Get.size != size) {
      sizeObs.value = Get.size;
      notify();
    }
  }

  void handleKeyboard() {
    if (Platform.hasKeyboard) {
      final keyboardVisible = Get.window.viewInsets.bottom != 0;
      if (isKeyboardVisible != keyboardVisible) {
        isKeyboardVisible = keyboardVisible;
        if (keyboardVisible == false) {
          Keyboard.removeFocus();
        }
      }
    }
  }

  set isKeyboardVisible(bool value) {
    if (value != keyboardVisible.value) {
      keyboardVisible.value = value;
    }
  }

  void notifyOrientation() {
    orientation.value =
        width > height ? Orientation.landscape : Orientation.portrait;
  }

  void notifyMenu() {
    if (menuAnimating.value) return;
    menuAnimating.value = true;
    final display = willDisplayCollapsed || willDisplayLarge;
    final dockerOpening = display && !Menu.isDocked;
    if (dockerOpening) {
      displayMenu.value = true;
      menuWidth.value = 0;
    }
    if (willDisplayLarge) {
      ScaffoldService().navCollapsed.value = false;
      menuWidth.value = Menu.fullWidth;
    } else if (willDisplayCollapsed) {
      Future.delayed(
          Duration(milliseconds: dockerOpening ? Menu.animationDuration : 0),
          () {
        ScaffoldService().navCollapsed.value = true;
        menuWidth.value = Menu.collapsedWidth;
      });
    } else if (!display) {
      Future.delayed(
          Duration(milliseconds: display ? Menu.animationDuration : 0),
          () => menuWidth.value = 0);
    }
    if (!dockerOpening) {
      Future.delayed(Duration(milliseconds: Menu.animationDuration),
          () => displayMenu.value = display);
    }
    Future.delayed(Duration(milliseconds: Menu.animationDuration),
        () => menuAnimating.value = false);
  }

  void notifyDiagonal() {
    if (width != 0 && height != 0) {
      diagonalInches.value = sqrt(pow(width * Screen.pixelRatio, 2) +
              pow(height * Screen.pixelRatio, 2)) /
          (Screen.pixelRatio * Screen.dpi);
    }
  }

  void notify() {
    notifyOrientation();
    notifyDiagonal();
    notifyMenu();
  }
}
