import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '../statics/nav.dart';
import 'button_dispatcher.dart';
import 'mouse_drag_scroll_behavior.dart';
import 'responsive.dart';

/// Hold the back button dispatcher to call it with Nav.back
late final ButtonDispatcher dispatcher;

class App extends StatelessWidget {
  final String title;
  final String? initialRoute;
  final Bindings? initialBindings;
  final List<GetPage> routes;
  final List<Locale>? locales;
  final ThemeData? lightTheme;
  final ThemeData? darkTheme;

  /// Use system default if darkMode is null
  final bool useSystemThemeMode;

  /// Callback that allow to select darkMode on start
  final bool? Function()? darkMode;

  /// Triggered before the back button or Nav.back callback is handled
  /// If the function do not return or return null the default behavior is
  /// called, if the function return true the back will be called and if the
  /// fuction return false no pop will happen
  final bool? Function()? onBack;

  /// Triggered if back button or Nav.back should close the app (empty history)
  /// If the function do not return or return null the default behavior is
  /// called, if the function return true the back will be called and if the
  /// fuction return false no pop will happen
  final bool? Function()? onExit;

  App(
      {Key? key,
      required this.title,
      required this.routes,
      this.initialRoute,
      this.initialBindings,
      this.onBack,
      this.onExit,
      this.lightTheme,
      this.darkMode,
      this.locales,
      this.useSystemThemeMode = true,
      this.darkTheme})
      : super(key: key) {
    dispatcher = ButtonDispatcher(onBack: onBack, onExit: onExit);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: title,
      onReady: () => initialRoute != null ? Nav.offAll(initialRoute!) : null,
      getPages: routes,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (BuildContext context, Widget? widget) => Responsive(widget),
      supportedLocales: locales ?? [],
      backButtonDispatcher: dispatcher,
      scrollBehavior: MouseDragScrollBehavior(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: darkMode?.call() == null && useSystemThemeMode
          ? ThemeMode.system
          : darkMode?.call() == true
              ? ThemeMode.dark
              : ThemeMode.light,
    );
  }

  void run() async {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    WidgetsFlutterBinding.ensureInitialized();

    if (initialBindings?.dependencies is Future<dynamic> Function()) {
      await (initialBindings?.dependencies() as Future<dynamic>);
    } else {
      initialBindings?.dependencies();
    }
    runApp(this);
  }
}
