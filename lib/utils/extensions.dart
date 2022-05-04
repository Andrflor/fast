import 'dart:math';

import 'package:fast/utils/typedef.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../statics/design.dart';
import '../statics/platform.dart';
import '../statics/screen.dart';
import '../widgets/app.dart';

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
      App.isDarkMode ? brighter(percent) : darker(percent);
}

extension StringCasingExtension on String {
  String get capital =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String get camel => replaceAll(RegExp('\n+'), '\n')
      .split('\n')
      .map((str) => str.capital)
      .join('\n');
  String get label => this + ': ';

  String itp(Map<String, String> kwargs) {
    String value = tr;
    for (var kwarg in kwargs.entries) {
      value = value.replaceAll('\$${kwarg.key}', kwarg.value.toString());
    }
    return value;
  }
}

extension RxIterableOperators<T> on Iterable<Rx<T>> {
  Rx<T> fuse() => fold(first.clone(), (i, e) => i..bind(e));
}

extension RxIterableListOperators<T> on Iterable<RxList<T>> {
  RxList<T> fuse() => fold(first.clone(), (i, e) => i..bind(e));
}

extension RxIterableSetOperators<T> on Iterable<RxSet<T>> {
  RxSet<T> fuse() => fold(first.clone(), (i, e) => i..bind(e));
}

extension RxIterableMapOperators<K, V> on Iterable<RxMap<K, V>> {
  RxMap<K, V> fuse() => fold(first.clone(), (i, e) => i..bind(e));
}

extension RxOperators<T> on Rx<T> {
  Rx<S> pipe<S>(S Function(T e) convert) =>
      convert(value).obs..bindStream(stream.map(convert));

  Rx<T> obsWhere(bool Function(T e) test) =>
      value.obs..bindStream(stream.where((e) => test(e)));

  Rx<T> clone() => value.obs..bindStream(stream);
  void bind(Rx<T> other) => bindStream(other.stream);
}

extension RxListOperators<T> on RxList<T> {
  Rx<S> pipe<S>(S Function(List<T> e) convert) =>
      (convert(call())).obs..bindStream(stream.map(convert));

  RxList<T> obsWhere(bool Function(List<T> e) test) =>
      call().obs..bindStream(stream.where((e) => test(e)));

  RxList<T> clone() => call().obs..bindStream(stream);
  void bind(RxList<T> other) => bindStream(other.stream);
}

extension RxSetOperators<T> on RxSet<T> {
  Rx<S> pipe<S>(S Function(Set<T> e) convert) =>
      (convert(call())).obs..bindStream(stream.map(convert));

  RxSet<T> obsWhere(bool Function(Set<T> e) test) =>
      call().obs..bindStream(stream.where((e) => test(e)));

  RxSet<T> clone() => call().obs..bindStream(stream);
  void bind(RxSet<T> other) => bindStream(other.stream);
}

extension RxMapOperators<K, V> on RxMap<K, V> {
  Rx<S> pipe<S>(S Function(Map<K, V> e) convert) =>
      (convert(call())).obs..bindStream(stream.map(convert));

  RxMap<K, V> obsWhere(bool Function(Map<K, V> e) test) =>
      call().obs..bindStream(stream.where((e) => test(e)));

  RxMap<K, V> clone() => call().obs..bindStream(stream);
  void bind(RxMap<K, V> other) => bindStream(other.stream);
}

extension NullOperand on num? {
  operator +(num? n) =>
      this == null && n == null ? null : (n ?? 0) + (this ?? 0);

  operator *(num? n) =>
      this == null && n == null ? null : (n ?? 0) * (this ?? 0);

  operator /(num? n) =>
      this == null && n == null ? null : (this ?? 0) / (n ?? 1);
}

extension Physical on num {
  num get pp => this * Screen.dpi / 96;
  num get h => this * (Platform.isDesktop ? 1 : Design.hScale);
  num get w => this * (Platform.isDesktop ? 1 : Design.wScale);
}
