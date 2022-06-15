import 'package:fast/statics/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:yaml/yaml.dart';

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
  final String translationFile;
  final bool yamlI18n;
  final bool debugBanner;
  final Color? Function(bool)? navigationBarColor;
  final Color? Function(bool)? statusBarColor;

  static GetMaterialController get _controller => Get.rootController;

  static void restart() => _controller.restartApp();

  static bool get isDarkMode => Get.isDarkMode;

  static set themeMode(ThemeMode themeMode) => Get.changeThemeMode(themeMode);
  static ThemeMode get themeMode =>
      isDarkMode ? ThemeMode.dark : ThemeMode.light;

  static set theme(ThemeData theme) => Get.changeTheme(theme);
  static ThemeData get theme => Get.theme;

  static Locale? get currentLocale => Get.locale;

  static Locale? get locale => Get.deviceLocale;
  static set locale(Locale? loc) => loc == null ? null : Get.updateLocale(loc);

  /// Use system default if darkMode is null
  final bool useSystemThemeMode;

  /// Callback that alow to select local on start
  late final String? Function()? _locale;

  /// Callback that allow to select darkMode on start
  final bool? Function()? darkMode;

  /// Triggered before the back button or Nav.back callback is handled
  /// If the function do not return or return null the default behavior is
  /// called, if the function return true the back will be called and if the
  /// fuction return false no pop will happen
  final Future<bool?> Function()? onBack;

  /// Triggered if back button or Nav.back should close the app (empty history)
  /// If the function do not return or return null the default behavior is
  /// called, if the function return true the back will be called and if the
  /// fuction return false no pop will happen
  final Future<bool?> Function()? onExit;

  late final Map<String, Map<String, String>>? _translations;

  App(
      {Key? key,
      required this.title,
      required this.routes,
      this.initialRoute,
      this.initialBindings,
      this.onBack,
      this.onExit,
      this.statusBarColor,
      this.navigationBarColor,
      final String? Function()? locale,
      this.lightTheme,
      this.darkMode,
      this.translationFile = 'assets/translations.yaml',
      this.yamlI18n = false,
      this.debugBanner = false,
      this.locales,
      this.useSystemThemeMode = true,
      this.darkTheme})
      : super(key: key) {
    _locale = locale;
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
      translationsKeys: _translations,
      defaultTransition: Transition.fadeIn,
      debugShowCheckedModeBanner: debugBanner,
      locale: Locale(_locale?.call() != null &&
              (locales ?? [])
                  .map((e) => e.languageCode)
                  .contains(_locale?.call())
          ? _locale!.call()!
          : 'en'),
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
    WidgetsFlutterBinding.ensureInitialized();

    _translations =
        yamlI18n ? await (_loadTranslations(translationFile)) : null;

    if (initialBindings?.dependencies is Future<dynamic> Function()) {
      await (initialBindings?.dependencies() as Future<dynamic>);
    } else {
      initialBindings?.dependencies();
    }

    final isDarkMode = darkMode?.call() ?? Platform.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: statusBarColor?.call(isDarkMode),
      systemNavigationBarColor: navigationBarColor?.call(isDarkMode),
    ));
    runApp(this);
  }
}

Future<Map<String, Map<String, String>>> _loadTranslations(
    String filename) async {
  final Map<String, Map<String, String>> translations = {};
  final data = await rootBundle.loadString(filename);
  for (var entry in (loadYaml(data) as YamlMap).entries) {
    for (var translation in (entry.value as YamlMap).entries) {
      if (!translations.keys.contains(translation.key)) {
        translations[translation.key] = {};
      }
      translations[translation.key]![entry.key] = translation.value;
    }
  }
  return translations;
}
