import 'package:flutter/material.dart';

import '../statics/menu.dart';
import '../statics/nav.dart';

class ButtonDispatcher extends RootBackButtonDispatcher {
  final Future<bool?> Function()? onBack;
  final Future<bool?> Function()? onExit;

  ButtonDispatcher({this.onBack, this.onExit});

  @override
  Future<bool> didPopRoute() async {
    Nav.onBack();
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

    Nav.onNav(Nav.history.length >= 2
        ? Nav.history[Nav.history.length - 2].location ?? ''
        : '');

    return await Nav.pop();
  }
}
