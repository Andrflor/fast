import 'package:get/get.dart';

import '../statics/design.dart';
import '../statics/platform.dart';
import '../statics/screen.dart';

export 'package:get/get_utils/src/extensions/context_extensions.dart';

extension ViewExtensions<T> on GetView<T> {
  T get c => controller;
}

extension StringCasingExtension on String {
  String get capital =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String get camel => replaceAll(RegExp('\n+'), '\n')
      .split('\n')
      .map((str) => str.capital)
      .join('\n');
  String get label => this + ': ';
}

extension Physical on num {
  get pp => this * Screen.dpi / 96;
  get h => this * (Platform.isDesktop ? 1 : Design.hScale);
  get w => this * (Platform.isDesktop ? 1 : Design.wScale);
}
