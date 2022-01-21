import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../services/scaffold_layout_controller.dart';
import '../services/scaffold_service.dart';
import '../utils/typedef.dart';

class AdaptiveScaffold extends View<ScaffoldService> {
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final Widget? drawer;
  final DrawerCallback? onDrawerChanged;
  final Widget? endDrawer;
  final DrawerCallback? onEndDrawerChanged;
  final Color? drawerScrimColor;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;
  final rebuild = false.obs;
  late final Key _key;

  AdaptiveScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
  }) : super(key: key) {
    _key = key ?? GlobalKey<ScaffoldState>();
    controller.openDelegate = open;
    controller.closeDelegate = close;
    controller.isOpenDelegate = isDrawerOpen;
  }

  bool isDrawerOpen() =>
      (_key as GlobalKey<ScaffoldState>).currentState?.isDrawerOpen ?? false;

  void open() {
    if (!isDrawerOpen()) {
      (_key as GlobalKey<ScaffoldState>).currentState?.openDrawer();
    }
  }

  void close() {
    if (isDrawerOpen()) {
      (_key as GlobalKey<ScaffoldState>).currentState?.openEndDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ObxBuilder<ScaffoldLayoutController>(
      init: controller.layoutController,
      builder: (layout) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (layout.isDocked) drawer!,
          Expanded(
            child: Scaffold(
              key: _key,
              appBar: (appBar is AppBar)
                  ? controller.injectAppBar((appBar as AppBar))
                  : appBar,
              body: body,
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: floatingActionButtonLocation,
              floatingActionButtonAnimator: floatingActionButtonAnimator,
              persistentFooterButtons: persistentFooterButtons,
              drawer: appBar == null
                  ? null
                  : layout.isDocked
                      ? null
                      : drawer,
              onDrawerChanged: onDrawerChanged,
              endDrawer: endDrawer,
              onEndDrawerChanged: onEndDrawerChanged,
              bottomNavigationBar: bottomNavigationBar,
              bottomSheet: bottomSheet,
              backgroundColor: backgroundColor,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
              primary: primary,
              drawerDragStartBehavior: drawerDragStartBehavior,
              extendBody: extendBody,
              extendBodyBehindAppBar: extendBodyBehindAppBar,
              drawerScrimColor: drawerScrimColor,
              drawerEdgeDragWidth: drawerEdgeDragWidth,
              drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
              endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
              restorationId: restorationId,
            ),
          ),
        ],
      ),
    );
  }
}