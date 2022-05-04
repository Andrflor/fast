import 'dart:math' as math show min, max;

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../services/responsive_service.dart';
import 'nav.dart';
import 'platform.dart';
import 'menu.dart';

abstract class Screen {
  static final ResponsiveService _responsiveService = ResponsiveService();

  static double get height => _responsiveService.height;
  static double get width => _responsiveService.width;
  static double get viewWidth => width - Menu.width;

  static Size get size => _responsiveService.size;
  static Rx<Size> get sizeChanged => _responsiveService.sizeChanged;

  static double get min => math.min(width, height);
  static double get max => math.max(width, height);

  static double get pixelRatio => Get.pixelRatio;
  static double get ratio => height / width;

  static double get statusBarHeight =>
      MediaQuery.of(Nav.context).viewPadding.top;
  static double get bottomBarHeight =>
      MediaQuery.of(Nav.context).viewPadding.bottom;

  static Orientation get orientation => _responsiveService.orientation.value;
  static bool get isPortrait => orientation == Orientation.portrait;
  static bool get isLandscape => !isPortrait;

  static double get diagonalInches => _responsiveService.diagonalInches.value;
  static int get dpi => Platform.isMobile ? 150 : 96;

  static bool get isLarge => diagonalInches > 7;
  static bool get isSmall => diagonalInches < 3;
  static bool get isMedium => !isLarge && !isMedium;
}
