import 'package:flutter/material.dart';
import 'package:get/get.dart';

export 'package:get/get_connect/http/src/response/response.dart';
export 'package:get/get_connect/http/src/status/http_status.dart';
export 'package:get/get_instance/src/bindings_interface.dart';
export 'package:get/get_navigation/src/routes/transitions_type.dart';
export 'package:get/get_rx/src/rx_types/rx_types.dart';
export 'package:get/get_rx/src/rx_workers/rx_workers.dart';
export 'package:get/get_state_manager/src/rx_flutter/rx_notifier.dart';
export 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

// Some syntaxic sugar
typedef View<T> = GetView<T>;
typedef Controller = GetxController;
typedef Service = GetxService;
typedef Toast = GetSnackBar;
typedef Utils = GetUtils;
typedef Middleware = GetMiddleware;
typedef NavConfig = GetNavConfig;
typedef Connect = GetConnect;
typedef NavPage = GetPage;
typedef RouterOutlet = GetRouterOutlet;
typedef ObxBuilder<T extends Controller> = GetBuilder<T>;
typedef Json = Map<String, dynamic>;

/// Syntaxic sugar for Theme.of(context)
// ignore: non_constant_identifier_names
ThemeData get Theming => Get.theme;

/// Syntaxic sugar for TextTheming
// ignore: non_constant_identifier_names
TextTheme get TextTheming => Theming.textTheme;

/// Syntaxic sugar for TextTheming
// ignore: non_constant_identifier_names
ColorScheme get Palette => Theming.colorScheme;
