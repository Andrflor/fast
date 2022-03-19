import 'dart:math';

import 'package:fast/utils/typedef.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../statics/design.dart';
import '../statics/platform.dart';
import '../statics/screen.dart';

export 'package:get/get_utils/src/extensions/context_extensions.dart';

extension ViewExtensions<T> on GetView<T> {
  T get c => controller;
}

extension Brightness on Color {
  int _percent(int color, int percent) =>
      min(255, max(0, (color * (1 + percent / 100)).round()));

  Color brighter(int percent) => withRed(_percent(red, percent))
      .withBlue(_percent(blue, percent))
      .withGreen(_percent(green, percent));
  Color darker(int percent) => brighter(-percent);
  Color adaptive(int percent) =>
      Screen.isDarkMode ? brighter(percent) : darker(percent);
}

extension StringCasingExtension on String {
  String get capital =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String get camel => replaceAll(RegExp('\n+'), '\n')
      .split('\n')
      .map((str) => str.capital)
      .join('\n');
  String get label => this + ': ';

  dynamic get itp => InterpolableString(tr);
}

class InterpolableString {
  late final VarArgsCallback callback;
  InterpolableString(String _value) {
    callback = ((args, kwargs) {
      String value = _value;
      for (var i = 0; i < args.length; i++) {
        value = value.replaceAll('\$${i + 1}', args[i].toString());
      }
      for (var kwarg in kwargs.entries) {
        value = value.replaceAll('\$${kwarg.key}', kwarg.value.toString());
      }
      return value;
    });
  }

  static const _offset = 'Symbol("'.length;

  String call() => callback([], {});

  @override
  String noSuchMethod(Invocation invocation) {
    return callback(
      invocation.positionalArguments,
      invocation.namedArguments.map(
        (_k, v) {
          var k = _k.toString();
          return MapEntry(k.substring(_offset, k.length - 2), v);
        },
      ),
    );
  }
}

extension Physical on num {
  get pp => this * Screen.dpi / 96;
  get h => this * (Platform.isDesktop ? 1 : Design.hScale);
  get w => this * (Platform.isDesktop ? 1 : Design.wScale);
}
