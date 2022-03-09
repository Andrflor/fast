import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/app.dart' show dispatcher;
import '../utils/typedef.dart' show sleep;

class Nav {
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
    while (await delegate.canPopHistory()) {
      await delegate.popHistory();
    }
  }

  static Future<T> _to<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
    Transition? transition,
  }) async {
    if (transition == null) {
      return delegate.toNamed(page,
          arguments: arguments, parameters: parameters);
    }

    if (parameters != null) {
      final uri = Uri(path: page, queryParameters: parameters);
      page = uri.toString();
    }

    final decoder = Get.routeTree.matchRoute(page, arguments: arguments);
    decoder.replaceArguments(arguments);

    final completer = Completer<T>();

    if (decoder.route != null) {
      //TODO: remove this or make it only be used on the current route
      await delegate.pushHistory(
        GetNavConfig(
          currentTreeBranch: decoder.treeBranch
              .map(
                (e) => GetPage(
                  name: e.name,
                  page: e.page,
                  title: e.title,
                  participatesInRootNavigator: e.participatesInRootNavigator,
                  gestureWidth: e.gestureWidth,
                  maintainState: e.maintainState,
                  curve: e.curve,
                  alignment: e.alignment,
                  parameters: e.parameters,
                  opaque: e.opaque,
                  transitionDuration: e.transitionDuration,
                  popGesture: e.popGesture,
                  binding: e.binding,
                  bindings: e.bindings,
                  transition: transition,
                  customTransition: e.customTransition,
                  fullscreenDialog: e.fullscreenDialog,
                  children: e.children,
                  middlewares: e.middlewares,
                  unknownRoute: e.unknownRoute,
                  arguments: e.arguments,
                  showCupertinoParallax: e.showCupertinoParallax,
                  preventDuplicates: e.preventDuplicates,
                ),
              )
              .toList(),
          location: page,
          state: null,
        ),
      );

      return completer.future;
    } else {
      return Future.value();
    }
  }

  static Future<T?>? to<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
    Transition? transition,
  }) async =>
      _to<T>(page,
          arguments: arguments, parameters: parameters, transition: transition);

  static Future<T?>? off<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
    Transition? transition,
  }) async {
    history.removeLast();
    return to<T>(page,
        arguments: arguments, parameters: parameters, transition: transition);
  }

  static Future<T?>? offAll<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
    Transition? transition,
  }) async {
    await clearHistory();
    return off<T>(page,
        arguments: arguments, parameters: parameters, transition: transition);
  }
}
