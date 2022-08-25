import 'package:flutter/material.dart';

import '../statics/menu.dart';
import '../statics/nav.dart';

class ButtonDispatcher extends RootBackButtonDispatcher {
  final Future<bool?> Function()? onBack;
  final Future<bool?> Function()? onExit;

  ButtonDispatcher({this.onBack, this.onExit});

  Future<bool> back<T>() async {
    if (!Nav.canBack()) {
      return true;
    }

    final onBackResult = await onBack?.call();
    if (onBackResult != null) {
      return onBackResult;
    }

    if (Menu.isOpen) {
      Menu.close();
      return true;
    }

    final canPop = await Nav.canPop();
    if (!(Nav.isAnyOverlay || canPop)) {
      final onExitResult = await onExit?.call();
      if (onExitResult != null) {
        return onExitResult;
      }
    }

    return canPop ? Nav.pop() : super.didPopRoute();
  }

  @override
  Future<bool> didPopRoute() async {
    String? path;
    if (!Nav.isAnyOverlay && Nav.history.length >= 2) {
      path = Nav.history[Nav.history.length - 2].pageSettings?.path;
    }

    return (await NavIntent(path ?? '', NavIntents.back).navigate<bool>()) ??
        true;
  }
}
