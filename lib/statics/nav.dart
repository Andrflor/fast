import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/app.dart' show dispatcher;
import '../utils/typedef.dart' show sleep, obs;

abstract class Nav {
  static GetDelegate delegate = Get.rootDelegate;
  static List<GetNavConfig> get history => delegate.history;
  static Map<String, String>? get parameters =>
      delegate.currentConfiguration?.currentPage?.parameters;
  static String? parameter(String? name) => parameters?[name];
  static String? get then => parameter("then");
  static String get current =>
      delegate.currentConfiguration!.currentPage?.name ?? "";
  static bool isCurrent(String route) => current.contains(route);
  static Future<bool> back() async => await dispatcher.didPopRoute();
  static Future<bool> pop() async =>
      await delegate.popRoute(popMode: PopMode.History);
  static Future<bool> canPop() async => await delegate.canPopHistory();

  static BuildContext get context => Get.context!;

  static Future<void> loaded() async {
    while (Get.context == null) {
      await sleep(50);
    }
  }

  static final hasBottomSheet = false.obs;
  static final hasDialog = false.obs;
  static final hasOverlay = false.obs;
  static final hasDatePicker = false.obs;
  static final canBack = true.obs;
  static final canNav = true.obs;
  static final onBack = obs;
  static final onNav = "".obs;

  static Future<T?>? Function<T>()? nextNavIntent;

  static bool get isSnackbar => Get.isSnackbarOpen;

  static bool get isBottomSheet => hasBottomSheet.value;
  static bool get isDialog => hasDialog.value;
  static bool get isOverlay => hasOverlay.value;
  static bool get isDatePicker => hasDatePicker.value;

  static bool get isAnyOverlay =>
      isBottomSheet || isDialog || isOverlay || isDatePicker;

  void closeAllSnackbars() {
    SnackbarController.cancelAllSnackbars();
  }

  Future<void> closeCurrentSnackbar() async {
    if (isSnackbar) {
      await SnackbarController.closeCurrentSnackbar();
    }
  }

  static Future<void> clearHistory() async {
    while (await canPop()) {
      await pop();
    }
  }

  static Future<T?>? resume<T>() async {
    final callback = nextNavIntent;
    nextNavIntent = null;
    return await callback?.call<T>();
  }

  static Future<T?>? to<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) async {
    nextNavIntent = <T>() async {
      return delegate.toNamed<T>(page,
          arguments: arguments, parameters: parameters);
    };
    Nav.onNav(page);
    if (Nav.canNav()) return resume<T>();
  }

  static Future<T?>? off<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) async {
    nextNavIntent = <T>() async {
      if (await canPop()) {
        await pop();
      }
      return to<T>(page, arguments: arguments, parameters: parameters);
    };
    Nav.onNav(page);
    if (Nav.canNav()) return resume<T>();
  }

  static Future<T?>? offAll<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) async {
    nextNavIntent = <T>() async {
      await clearHistory();
      return off<T>(page, arguments: arguments, parameters: parameters);
    };
    Nav.onNav(page);
    if (Nav.canNav()) return resume<T>();
  }
}
