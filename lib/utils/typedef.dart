import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:get/get.dart' hide ever, everAll, interval, debounce, once;

import 'package:get/get.dart' as workerlib
    show ever, everAll, interval, debounce, once;

export 'package:get/get_connect/http/src/response/response.dart';
export 'package:get/get_connect/http/src/status/http_status.dart';
export 'package:get/get_instance/src/bindings_interface.dart';
export 'package:get/get_navigation/src/routes/transitions_type.dart';
export 'package:get/get_rx/src/rx_types/rx_types.dart';
export 'package:get/get_state_manager/src/rx_flutter/rx_notifier.dart';
export 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
export 'package:get/get_rx/src/rx_workers/rx_workers.dart';

// Some syntaxic sugar
typedef ControlledWidget<T extends GetLifeCycleBase> = GetWidget<T>;
typedef LifeCycleController = SuperController;
typedef Service = GetxService;
typedef BareController = RxController;
typedef Toast = GetSnackBar;
typedef Utils = GetUtils;
typedef Middleware = GetMiddleware;
typedef NavConfig = GetNavConfig;
typedef NavPage = GetPage;
typedef RouterOutlet = GetRouterOutlet;
typedef ObxBuilder<T extends GetxController> = GetBuilder<T>;
typedef Json = Map<String, dynamic>;

mixin ScrollCapability on GetxController {
  final ScrollController scroll = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scroll.addListener(_listener);
  }

  bool _canFetchBottom = true;

  bool _canFetchTop = true;

  void _listener() {
    if (scroll.position.atEdge) {
      _checkIfCanLoadMore();
    }
    onScroll();
  }

  Future<void> _checkIfCanLoadMore() async {
    if (scroll.position.pixels == 0) {
      if (!_canFetchTop) return;
      _canFetchTop = false;
      await onTopScroll();
      _canFetchTop = true;
    } else {
      if (!_canFetchBottom) return;
      _canFetchBottom = false;
      await onEndScroll();
      _canFetchBottom = true;
    }
  }

  Future<void> onEndScroll() async {}

  Future<void> onTopScroll() async {}

  Future<void> onScroll() async {}

  @override
  void onClose() {
    scroll.removeListener(_listener);
    super.onClose();
  }
}

abstract class Controller<T> extends GetxController with StateMixin<T> {
  final List<Worker> _workers = <Worker>[];

  @nonVirtual
  void loading([T? state]) {
    change(state ?? this.state, status: RxStatus.loading());
  }

  @nonVirtual
  void empty([T? state]) {
    change(state ?? this.state, status: RxStatus.empty());
  }

  @nonVirtual
  void success([T? state]) {
    change(state ?? this.state, status: RxStatus.success());
  }

  @nonVirtual
  void error([String? error, T? state]) {
    change(state ?? this.state, status: RxStatus.error(error));
  }

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
  void onClose() {
    disposeWorkers();
    super.onClose();
  }
}

abstract class View<T extends Controller> extends GetView<T> {
  const View({Key? key}) : super(key: key);

  @nonVirtual
  get model => controller.state;

  @nonVirtual
  String? get error => controller.status.errorMessage;

  Widget onSucces(BuildContext context) => const SizedBox.shrink();

  Widget onError(BuildContext context) => const SizedBox.shrink();

  Widget onLoading(BuildContext context) =>
      const Center(child: CircularProgressIndicator());

  Widget onEmpty(BuildContext context) => const SizedBox.shrink();

  @nonVirtual
  // ignore: non_constant_identifier_names
  Status(BuildContext context) {
    controller.obx((_) => onSucces(context),
        onError: (_) => onError(context),
        onEmpty: onEmpty(context),
        onLoading: onLoading(context));
  }
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
