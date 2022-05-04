import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/app.dart' show dispatcher;
import '../utils/typedef.dart' show sleep;
import '../utils/extensions.dart' show RxOperators;

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
  static Future<bool> closeOverlay() async =>
      Nav.isAnyOverlay ? await Nav.back() : false;
  static Future<bool> pop() async =>
      await delegate.popRoute(popMode: PopMode.History);
  static Future<bool> canPop() async => await delegate.canPopHistory();

  static BuildContext get context => Get.context!;

  static GlobalKey<NavigatorState>? nestedKey(dynamic key) =>
      Get.nestedKey(key);

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
  static final onNav = Rxn<NavIntent>(null);
  static final onBack = onNav.obsWhere((e) => e?.intent == NavIntents.back);

  static NavIntent? get nextNavIntent => onNav();
  static set nextNavIntent(NavIntent? navIntent) => onNav(navIntent);

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
    return await callback?.resume<T>();
  }

  static Future<T?>? to<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) async =>
      NavIntent(page, NavIntents.to,
              arguments: arguments, parameters: parameters)
          .navigate();

  static Future<T?>? off<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) async =>
      NavIntent(page, NavIntents.off,
              arguments: arguments, parameters: parameters)
          .navigate();

  static Future<T?>? offAll<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) async =>
      NavIntent(page, NavIntents.offAll,
              arguments: arguments, parameters: parameters)
          .navigate();
}

class NavIntent {
  final String page;
  final dynamic arguments;
  final Map<String, String>? parameters;
  final NavIntents intent;

  NavIntent(this.page, this.intent, {this.parameters, this.arguments}) {
    Nav.nextNavIntent = this;
  }

  Future<T?>? navigate<T>() async {
    if ((Nav.canNav() && intent != NavIntents.back) ||
        (Nav.canBack() && intent == NavIntents.back)) return Nav.resume<T>();
    return null;
  }

  Future<T?>? resume<T>() async {
    switch (intent) {
      case NavIntents.to:
        return to<T>();
      case NavIntents.off:
        return off<T>();
      case NavIntents.offAll:
        return offAll<T>();
      case NavIntents.back:
        return dispatcher.back<T>() as Future<T?>?;
    }
  }

  Future<T?>? to<T>() async => Nav.delegate
      .toNamed<T>(page, parameters: parameters, arguments: arguments);

  Future<T?>? off<T>() async {
    Nav.history.removeLast();
    return Nav.delegate
        .toNamed<T>(page, arguments: arguments, parameters: parameters);
  }

  Future<T?>? offAll<T>() async {
    await Nav.clearHistory();
    Nav.history.removeLast();
    return Nav.delegate
        .toNamed<T>(page, arguments: arguments, parameters: parameters);
  }
}

enum NavIntents {
  to,
  off,
  offAll,
  back,
}
