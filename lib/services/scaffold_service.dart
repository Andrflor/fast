import 'package:fast/services/responsive_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';

import '../statics/dep.dart';
import '../statics/menu.dart';
import '../utils/typedef.dart';
import 'scaffold_layout_controller.dart';

class ScaffoldService {
  Function()? openDelegate;
  Function()? closeDelegate;
  bool Function()? isOpenDelegate;

  final navCollapsed = false.obs;
  final layoutController = Dep.put(ScaffoldLayoutController(), permanent: true);

  bool get isOpen => isOpenDelegate?.call() ?? false;

  static final ScaffoldService _instance = ScaffoldService._();

  factory ScaffoldService() => _instance;

  ScaffoldService._() {
    ever(navCollapsed, (bool value) {
      ResponsiveService().menuWidth.value =
          value ? Menu.collapsedWidth : Menu.fullWidth;
    });
  }

  AppBar injectAppBar(AppBar appBar) {
    return AppBar(
      key: appBar.key,
      title: appBar.title,
      shape: appBar.shape,
      bottom: appBar.bottom,
      leading: appBar.leading ??
          Obx(
            () => IconButton(
                onPressed: Menu.isDocked ? Menu.collapse : Menu.open,
                icon: Icon(Menu.isDocked
                    ? (Menu.isCollapsed
                        ? Icons.chevron_right
                        : Icons.chevron_left)
                    : Icons.menu)),
          ),
      primary: appBar.primary,
      elevation: appBar.elevation,
      iconTheme: appBar.iconTheme,
      actions: appBar.actions,
      centerTitle: appBar.centerTitle,
      shadowColor: appBar.shadowColor,
      leadingWidth: appBar.leadingWidth,
      flexibleSpace: appBar.flexibleSpace,
      bottomOpacity: appBar.bottomOpacity,
      toolbarHeight: appBar.toolbarHeight,
      toolbarOpacity: appBar.toolbarOpacity,
      titleTextStyle: appBar.titleTextStyle,
      backgroundColor: appBar.backgroundColor,
      foregroundColor: appBar.foregroundColor,
      actionsIconTheme: appBar.actionsIconTheme,
      toolbarTextStyle: appBar.toolbarTextStyle,
      systemOverlayStyle: appBar.systemOverlayStyle,
      excludeHeaderSemantics: appBar.excludeHeaderSemantics,
      automaticallyImplyLeading: appBar.automaticallyImplyLeading,
    );
  }
}
