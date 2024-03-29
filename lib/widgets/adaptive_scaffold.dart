import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../services/responsive_service.dart';
import '../services/scaffold_service.dart';
import '../utils/typedef.dart';

class AdaptiveScaffold extends StatefulWidget {
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
  }

  @override
  State<AdaptiveScaffold> createState() => AdaptiveScaffoldState();
}

class AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  @override
  void initState() {
    _scaffoldService.pushScaffold(this);
    super.initState();
  }

  final _scaffoldService = ScaffoldService();

  bool isDrawerOpen() =>
      (widget._key as GlobalKey<ScaffoldState>).currentState?.isDrawerOpen ??
      false;

  void open() {
    if (!isDrawerOpen()) {
      (widget._key as GlobalKey<ScaffoldState>).currentState?.openDrawer();
    }
  }

  void close() {
    if (isDrawerOpen()) {
      (widget._key as GlobalKey<ScaffoldState>).currentState?.openEndDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ObxValue(
      (RxBool data) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.value) widget.drawer!,
          Expanded(
            child: Scaffold(
              key: widget._key,
              appBar: (widget.appBar is AppBar)
                  ? _scaffoldService.injectAppBar((widget.appBar as AppBar))
                  : widget.appBar,
              body: widget.body,
              floatingActionButton: widget.floatingActionButton,
              floatingActionButtonLocation: widget.floatingActionButtonLocation,
              floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
              persistentFooterButtons: widget.persistentFooterButtons,
              drawer: widget.appBar == null
                  ? null
                  : data.value
                      ? null
                      : widget.drawer,
              onDrawerChanged: widget.onDrawerChanged,
              endDrawer: widget.endDrawer,
              onEndDrawerChanged: widget.onEndDrawerChanged,
              bottomNavigationBar: widget.bottomNavigationBar,
              bottomSheet: widget.bottomSheet,
              backgroundColor: widget.backgroundColor,
              resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
              primary: widget.primary,
              drawerDragStartBehavior: widget.drawerDragStartBehavior,
              extendBody: widget.extendBody,
              extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
              drawerScrimColor: widget.drawerScrimColor,
              drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
              drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
              endDrawerEnableOpenDragGesture:
                  widget.endDrawerEnableOpenDragGesture,
              restorationId: widget.restorationId,
            ),
          ),
        ],
      ),
      ResponsiveService().displayMenu,
    );
  }

  @override
  void dispose() {
    _scaffoldService.removeScaffold(this);
    super.dispose();
  }
}
