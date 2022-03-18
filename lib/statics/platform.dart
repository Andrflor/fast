import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:io' as io show Platform;

import './screen.dart';

abstract class Platform {
  static bool isAndroid = kIsWeb
      ? defaultTargetPlatform == TargetPlatform.android
      : io.Platform.isAndroid;

  static bool isFuchsia = kIsWeb
      ? defaultTargetPlatform == TargetPlatform.fuchsia
      : io.Platform.isFuchsia;

  static bool isIOS =
      kIsWeb ? defaultTargetPlatform == TargetPlatform.iOS : io.Platform.isIOS;

  static bool isWindows = kIsWeb
      ? defaultTargetPlatform == TargetPlatform.windows
      : io.Platform.isWindows;

  static bool isMacOS = kIsWeb
      ? defaultTargetPlatform == TargetPlatform.macOS
      : io.Platform.isMacOS;

  static bool isLinux = kIsWeb
      ? defaultTargetPlatform == TargetPlatform.linux
      : io.Platform.isLinux;

  static bool isWeb = kIsWeb;

  static bool isMobile = isAndroid || isFuchsia || isIOS;

  static bool isDesktop = isWindows || isMacOS || isLinux;

  static bool get isTablet => isMobile && Screen.isLarge;

  static bool get isSmartPhone => isMobile && !isTablet;

  static bool hasKeyboard = !isDesktop;

  static Locale? get currentLocale => Get.locale;

  static Locale? get locale => Get.deviceLocale;
  static set locale(Locale? loc) => loc == null ? null : Get.updateLocale(loc);
}
