import 'dart:async';

import 'package:fast/statics/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_widget_cache.dart';
import 'package:meta/meta.dart';

import 'package:get/get.dart'
    hide ever, everAll, interval, debounce, once, GetWidget;

import 'package:get/get.dart' as workerlib
    show ever, everAll, interval, debounce, once;

export 'package:get/get_connect/http/src/response/response.dart';
export 'package:get/get_connect/http/src/status/http_status.dart';
export 'package:get/get_instance/src/bindings_interface.dart';
export 'package:get/get_navigation/src/routes/transitions_type.dart';
export 'package:get/get_rx/src/rx_types/rx_types.dart';
export 'package:get/get_state_manager/src/rx_flutter/rx_notifier.dart';
export 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
export 'package:get/get_state_manager/src/rx_flutter/rx_ticket_provider_mixin.dart';
export 'package:get/get_utils/src/extensions/internacionalization.dart';
export 'package:get/get_navigation/src/routes/custom_transition.dart';
export 'package:get/get_rx/src/rx_workers/rx_workers.dart'
    show Worker, Workers, WorkerCallback;

// Some syntaxic sugar
typedef ControlledWidget<T extends WidgetAware> = GetWidget<T>;
typedef LifeCycleController = SuperController;
typedef BareController = RxController;
typedef Toast = GetSnackBar;
typedef Utils = GetUtils;
typedef Middleware = GetMiddleware;
typedef NavConfig = GetNavConfig;
typedef NavPage = GetPage;
typedef RouterOutlet = GetRouterOutlet;
typedef ObxBuilder<T extends GetxController> = GetBuilder<T>;
typedef Json = Map<String, dynamic>;
abstract class Service = GetxService with AutoDispose;

extension NullOperand on num? {
  operator +(num? n) =>
      this == null && n == null ? null : (n ?? 0) + (this ?? 0);

  operator *(num? n) =>
      this == null && n == null ? null : (n ?? 0) * (this ?? 0);

  operator /(num? n) =>
      this == null && n == null ? null : (this ?? 0) / (n ?? 1);
}

typedef VarArgsCallback = dynamic Function(
    List<dynamic> args, Map<String, dynamic> kwargs);

abstract class AppException implements Exception {
  String get message => '';

  @override
  toString() => message == '' ? super.toString() : message;
}

class VarArgsFunction {
  final VarArgsCallback callback;
  static const _offset = 'Symbol("'.length;

  VarArgsFunction(this.callback);

  dynamic call() => callback([], {});

  @override
  dynamic noSuchMethod(Invocation invocation) {
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

RxVoid get obs => RxVoid();

class RxVoid extends Rx<void> {
  RxVoid() : super(null);

  @override
  void call([void v]) => refresh();
}

class Instantiator {
  static final _internal = <Type, Function>{};
  static T instantiate<T>() => _internal[T]?.call();

  static void register<T>(T Function() callback) => _internal[T] = callback;
}

Future<void> sleep(int milliseconds) async =>
    await Future.delayed(Duration(milliseconds: milliseconds));

void runAfterBuild(Function callback) {
  WidgetsBinding.instance?.addPostFrameCallback((_) => callback());
}

Worker runOnResize(WorkerCallback<Size> callback) {
  return workerlib.ever(Screen.sizeChanged, callback);
}

mixin ScrollCapability on GetxController {
  final ScrollController scroll = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scroll.addListener(_listener);
    WidgetsBinding.instance?.addPostFrameCallback(
        (_) => position.isScrollingNotifier.addListener(_valueListener));
  }

  RxBool scrolling = false.obs;

  bool get isScrolling => scrolling.value;
  set isScrolling(bool value) => scrolling.value = value;

  bool _canFetchBottom = true;

  bool _canFetchTop = true;

  void _listener() {
    if (scroll.position.atEdge) {
      _checkIfCanLoadMore();
    }
    onScroll();
  }

  void _valueListener() {
    position.isScrollingNotifier.value ? onStartScroll() : onEndScroll();
    isScrolling = position.isScrollingNotifier.value;
  }

  double get offset => scroll.offset;

  ScrollPosition get position => scroll.position;

  double get initialScrollOffset => scroll.initialScrollOffset;

  bool get hasClients => scroll.hasClients;

  @nonVirtual
  void attach(ScrollPosition position) => scroll.attach(position);

  @nonVirtual
  void detach(ScrollPosition position) => scroll.detach(position);

  @nonVirtual
  void jumpTo(double value) {
    if (hasClients) {
      scroll.jumpTo(value);
    }
  }

  @nonVirtual
  Future<void> animateTo(
    double offset, {
    required Duration duration,
    required Curve curve,
  }) async {
    if (!isScrolling && hasClients) {
      await scroll.animateTo(offset, duration: duration, curve: curve);
    }
  }

  Future<void> _checkIfCanLoadMore() async {
    if (position.pixels == 0) {
      if (!_canFetchTop) return;
      _canFetchTop = false;
      await onTopScroll();
      _canFetchTop = true;
    } else {
      if (!_canFetchBottom) return;
      _canFetchBottom = false;
      await onBottomScroll();
      _canFetchBottom = true;
    }
  }

  Future<void> onBottomScroll() async {}

  Future<void> onTopScroll() async {}

  void onScroll() {}

  void onStartScroll() {}

  void onEndScroll() {}

  @override
  void onClose() {
    scroll.removeListener(_listener);
    scroll.dispose();
    super.onClose();
  }
}

abstract class GetWidget<S extends WidgetAware?> extends GetWidgetCache {
  const GetWidget({Key? key}) : super(key: key);

  @protected
  final String? tag = null;

  S get controller => GetWidget._cache[this] as S;

  S get c => controller;

  static final _cache = Expando<WidgetAware>();

  @protected
  Widget build(BuildContext context);

  @override
  WidgetCache createWidgetCache() => _GetCache<S>();
}

mixin WidgetAware<T extends Widget> on GetLifeCycleBase {
  BuildContext? get context => _context;
  BuildContext? _context;

  T? get widget => _widget;
  T? _widget;

  void onBuild() {}

  void afterBuild() {}
}

class _GetCache<S extends WidgetAware?> extends WidgetCache<GetWidget<S>> {
  S? _controller;
  bool _isCreator = false;
  InstanceInfo? info;
  @override
  void onInit() {
    info = GetInstance().getInstanceInfo<S>(tag: widget!.tag);

    _isCreator = info!.isPrepared && info!.isCreate;

    if (info!.isRegistered) {
      _controller = Get.find<S>(tag: widget!.tag);
    }
    _controller?._widget = widget;

    GetWidget._cache[widget!] = _controller;
    super.onInit();
  }

  @override
  void onClose() {
    if (_isCreator) {
      Get.asap(() {
        widget!.controller!.onDelete();
        Get.log('"${widget!.controller.runtimeType}" onClose() called');
        Get.log('"${widget!.controller.runtimeType}" deleted from memory');
        GetWidget._cache[widget!] = null;
      });
    }
    info = null;
    super.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      _controller!._context = context;
      _controller!.onBuild();
      runAfterBuild(_controller!.afterBuild);
    }
    return widget!.build(context);
  }
}

mixin AutoDispose on GetLifeCycleBase {
  final List<Worker> _workers = <Worker>[];

  @nonVirtual
  Worker ever<T>(
    RxInterface<T> listener,
    WorkerCallback<T> callback, {
    dynamic condition = true,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    late final Worker worker;
    worker = workerlib.ever<T>(listener, callback,
        condition: condition, onError: onError, onDone: () {
      _workers.remove(worker);
      onDone?.call();
    }, cancelOnError: cancelOnError);
    _workers.add(worker);
    return worker;
  }

  @nonVirtual
  Worker everAll(
    List<RxInterface> listeners,
    WorkerCallback callback, {
    dynamic condition = true,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    late final Worker worker;
    worker = workerlib.everAll(listeners, callback,
        condition: condition, onError: onError, onDone: () {
      _workers.remove(worker);
      onDone?.call();
    }, cancelOnError: cancelOnError);
    _workers.add(worker);
    return worker;
  }

  @nonVirtual
  Worker once<T>(
    RxInterface<T> listener,
    WorkerCallback<T> callback, {
    dynamic condition = true,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    late final Worker worker;
    worker = workerlib.once<T>(listener, callback,
        condition: condition, onError: onError, onDone: () {
      _workers.remove(worker);
      onDone?.call();
    }, cancelOnError: cancelOnError);
    _workers.add(worker);
    return worker;
  }

  @nonVirtual
  Worker interval<T>(
    RxInterface<T> listener,
    WorkerCallback<T> callback, {
    Duration time = const Duration(seconds: 1),
    dynamic condition = true,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    late final Worker worker;
    worker = workerlib.interval<T>(listener, callback,
        condition: condition, time: time, onError: onError, onDone: () {
      _workers.remove(worker);
      onDone?.call();
    }, cancelOnError: cancelOnError);
    _workers.add(worker);
    return worker;
  }

  @nonVirtual
  Worker debounce<T>(
    RxInterface<T> listener,
    WorkerCallback<T> callback, {
    Duration? time,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    late final Worker worker;
    worker = workerlib.debounce<T>(listener, callback,
        time: time, onError: onError, onDone: () {
      _workers.remove(worker);
      onDone?.call();
    }, cancelOnError: cancelOnError);
    _workers.add(worker);
    return worker;
  }

  void disposeWorkers() {
    for (var worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
  }

  @override
  @mustCallSuper
  void onClose() {
    disposeWorkers();
    super.onClose();
  }
}

mixin WindowResizeListener on AutoDispose {
  @override
  void onInit() {
    super.onInit();
    runOnResize(onResize);
  }

  // Would be incredible to get view size instead
  void onResize(Size windowSize) {}

  @nonVirtual
  Worker runOnResize(WorkerCallback<Size> callback) {
    return ever(Screen.sizeChanged, callback);
  }
}

mixin SimpleState<T> on StateMixin<T> {
  @mustCallSuper
  void loading([T? state]) {
    change(state ?? this.state, status: RxStatus.loading());
  }

  @mustCallSuper
  void empty([T? state]) {
    change(state ?? this.state, status: RxStatus.empty());
  }

  @mustCallSuper
  void success([T? state]) {
    change(state ?? this.state, status: RxStatus.success());
  }

  @mustCallSuper
  void error([String? error, T? state]) {
    change(state ?? this.state, status: RxStatus.error(error));
  }

  T get model => value!;
}

abstract class Controller<T> = GetxController
    with StateMixin<T>, SimpleState<T>, AutoDispose, WidgetAware, AsyncInit;

mixin AsyncInit on GetLifeCycleBase {
  final _completer = Completer<void>();
  Future<void> get asyncInitDone => _completer.future;

  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    _completer.complete();
  }
}

abstract class View<T extends Controller> extends GetView<T> {
  const View({Key? key}) : super(key: key);

  @nonVirtual
  String get error => controller.status.errorMessage ?? '';

  Widget onSucces(BuildContext context) => const SizedBox.shrink();

  Widget onError(BuildContext context) => const SizedBox.shrink();

  Widget onLoading(BuildContext context) =>
      const Center(child: CircularProgressIndicator());

  Widget onEmpty(BuildContext context) => const SizedBox.shrink();

  @nonVirtual
  // ignore: non_constant_identifier_names
  Widget Status(BuildContext context) =>
      controller.obx((_) => onSucces(context),
          onError: (_) => onError(context),
          onEmpty: onEmpty(context),
          onLoading: onLoading(context));
}

/// Syntaxic sugar for Theme.of(context)
// ignore: non_constant_identifier_names
ThemeData get Theming => Get.theme;

/// Syntaxic sugar for TextTheming
// ignore: non_constant_identifier_names
TextTheme get TextTheming => Theming.textTheme;

/// Syntaxic sugar for TextTheming
// ignore: non_constant_identifier_names
ColorScheme get Palette => Theming.colorScheme;

abstract class RetryPolicy {
  const RetryPolicy();

  Future<Response<T>> run<T>(
      Future<Response<T>> Function() callback, bool Function(int?) retryCode,
      {RetryPolicy? retryPolicy});
}

class NoRetryPolicy extends RetryPolicy {
  @override
  Future<Response<T>> run<T>(
      Future<Response<T>> Function() callback, bool Function(int?) retryCode,
      {RetryPolicy? retryPolicy}) {
    return callback();
  }
}

class TimedRetryPolicy extends RetryPolicy {
  final int interval;
  final int duration;

  const TimedRetryPolicy(this.duration, this.interval);

  @override
  Future<Response<T>> run<T>(
      Future<Response<T>> Function() callback, bool Function(int?) retryCode,
      {RetryPolicy? retryPolicy}) async {
    var locked = true;
    var isOk = false;
    late Response<T> callResult;
    Future.delayed(Duration(milliseconds: duration), () => locked = false);
    while (locked) {
      callResult = await callback();
      isOk = !retryCode(callResult.statusCode);
      if (isOk) {
        locked = false;
      } else {
        await Future.delayed(Duration(milliseconds: interval));
      }
    }
    return callResult;
  }
}

class Connect extends GetConnect {
  static Future<Response<T>> noRetry<T>(
      Future<Response<T>> Function() fonction) {
    return fonction();
  }

  static RetryPolicy defaultRetryPolicy = const TimedRetryPolicy(800, 100);

  //ignore: prefer_function_declarations_over_variables
  static bool Function(int?) defaultRetryCode =
      (int? code) => code == null || code > 500;

  RetryPolicy retryPolicy = defaultRetryPolicy;
  bool Function(int?) retryCode = defaultRetryCode;

  Future<Response<T>> _retry<T>(Future<Response<T>> Function() callback,
      {RetryPolicy? retryPolicy, bool Function(int?)? retryCode}) {
    var _retryPolicy = retryPolicy;
    var _retryCode = retryCode;

    if (retryPolicy == null) _retryPolicy = this.retryPolicy;
    if (retryCode == null) _retryCode = this.retryCode;
    return _retryPolicy == null || _retryCode == null
        ? callback()
        : _retryPolicy.run(callback, _retryCode);
  }

  @override
  Future<Response<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    RetryPolicy? retryPolicy,
    bool Function(int?)? retryCode,
  }) {
    return _retry(
      () => super.get<T>(
        url,
        headers: headers,
        contentType: contentType,
        query: query,
        decoder: decoder,
      ),
      retryPolicy: retryPolicy,
      retryCode: retryCode,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String? url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
    RetryPolicy? retryPolicy,
    bool Function(int?)? retryCode,
  }) {
    return _retry(
      () => super.post<T>(
        url,
        body,
        headers: headers,
        contentType: contentType,
        query: query,
        decoder: decoder,
        uploadProgress: uploadProgress,
      ),
      retryPolicy: retryPolicy,
      retryCode: retryCode,
    );
  }

  @override
  Future<Response<T>> put<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
    RetryPolicy? retryPolicy,
    bool Function(int?)? retryCode,
  }) {
    return _retry(
      () => super.put<T>(
        url,
        body,
        headers: headers,
        contentType: contentType,
        query: query,
        decoder: decoder,
        uploadProgress: uploadProgress,
      ),
      retryPolicy: retryPolicy,
      retryCode: retryCode,
    );
  }

  @override
  Future<Response<T>> patch<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
    RetryPolicy? retryPolicy,
    bool Function(int?)? retryCode,
  }) {
    return _retry(
      () => super.patch<T>(
        url,
        body,
        headers: headers,
        contentType: contentType,
        query: query,
        decoder: decoder,
        uploadProgress: uploadProgress,
      ),
      retryPolicy: retryPolicy,
      retryCode: retryCode,
    );
  }

  @override
  Future<Response<T>> request<T>(
    String url,
    String method, {
    dynamic body,
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
    RetryPolicy? retryPolicy,
    bool Function(int?)? retryCode,
  }) {
    return _retry(
      () => super.request<T>(
        url,
        method,
        body: body,
        headers: headers,
        contentType: contentType,
        query: query,
        decoder: decoder,
        uploadProgress: uploadProgress,
      ),
      retryPolicy: retryPolicy,
      retryCode: retryCode,
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    RetryPolicy? retryPolicy,
    bool Function(int?)? retryCode,
  }) {
    return _retry(
      () => super.delete(
        url,
        headers: headers,
        contentType: contentType,
        query: query,
        decoder: decoder,
      ),
      retryPolicy: retryPolicy,
      retryCode: retryCode,
    );
  }
}
