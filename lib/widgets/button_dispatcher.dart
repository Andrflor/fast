import 'package:flutter/material.dart';

import '../statics/menu.dart';
import '../statics/nav.dart';

class ButtonDispatcher extends RootBackButtonDispatcher {
  final bool? Function()? onBack;
  final bool? Function()? onExit;

  ButtonDispatcher({this.onBack, this.onExit});

  @override
  Future<bool> didPopRoute() async {
    final onBackResult = onBack?.call();
    if (onBackResult != null) {
      return onBackResult;
    }

    if (Menu.isOpen) {
      Menu.close();
      return true;
    }

    if (!(Nav.isAnyOverlay || await Nav.canPop())) {
      final onExitResult = onExit?.call();
      if (onExitResult != null) {
        return onExitResult;
      }
    }

    return super.didPopRoute();
  }
}
