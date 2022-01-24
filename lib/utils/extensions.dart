import 'package:fast/utils/typedef.dart';
import 'package:get/get.dart';

import '../statics/design.dart';
import '../statics/platform.dart';
import '../statics/screen.dart';

export 'package:get/get_utils/src/extensions/context_extensions.dart';

extension ViewExtensions<T> on GetView<T> {
  T get c => controller;
}

extension WidgetExtensions<T extends GetLifeCycleBase?> on GetWidget<T> {
  T get c => controller;
}

extension WidgetExtension<T extends Controller> on GetWidget<T> {}

extension Plop on Type {}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String toCamelCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

extension Physical on num {
  get pp => this * Screen.dpi / 96;
  get h => this * (Platform.isDesktop ? 1 : Design.hScale);
  get w => this * (Platform.isDesktop ? 1 : Design.wScale);
}
