import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../statics/keyboard.dart';
import '../statics/menu.dart';
import '../statics/platform.dart';
import '../statics/screen.dart';
import 'scaffold_service.dart';

class ResponsiveService {
  bool get isKeyboardVisible => keyboardVisible.value;

  Size get size => sizeObs.value;
  double get width => size.width;
  double get height => size.height;

  static final ResponsiveService _instance = ResponsiveService._();

  ResponsiveService._();

  factory ResponsiveService() => _instance;

  static bool get willDisplayLarge =>
      Screen.width > 1000 && Screen.height > 500 && Screen.isLarge;

  static bool get willDisplayCollapsed =>
      Screen.width > 600 && Screen.height > 350 && Screen.isLarge;

  final sizeObs = const Size(0, 0).obs;
  final diagonalInches = 0.0.obs;

  final keyboardHeight = 0.0.obs;
  final keyboardVisible = false.obs;
  final menuWidth = 0.0.obs;
  final displayMenu = false.obs;
  final orientation = Orientation.portrait.obs;

  bool menuAnimating = false;

  void screenChanged() {
    if (Get.size != size) {
      sizeObs.value = Get.size;
      notify();
    }
  }

  void handleKeyboard() {
    if (Platform.hasKeyboard) {
      keyboardHeight.value = Get.window.viewInsets.bottom;
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
    final _navCollapsed = ScaffoldService().navCollapsed;
    if (menuAnimating) return;
    menuAnimating = true;
    final display = willDisplayCollapsed || willDisplayLarge;
    final dockerOpening = display && !Menu.isDocked;
    if (dockerOpening) {
      displayMenu.value = true;
      menuWidth.value = 0;
    }
    if (willDisplayLarge) {
      _navCollapsed.value = false;
      menuWidth.value = Menu.fullWidth;
    } else if (willDisplayCollapsed) {
      Future.delayed(
          Duration(milliseconds: dockerOpening ? Menu.animationDuration : 0),
          () {
        _navCollapsed.value = true;
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
        () => menuAnimating = false);
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
