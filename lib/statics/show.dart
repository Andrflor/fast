import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import './nav.dart';
import '../../utils/typedef.dart';

class Show {
  static int _overlays = 0;
  static int _dialogs = 0;
  static int _datePickers = 0;
  static int _bottomSheets = 0;

  static SnackbarController snackBar(Toast toast) => Get.showSnackbar(toast);

  static SnackbarController confirmSnack({
    required bool isOk,
    required String success,
    required String error,
  }) =>
      snackBar(
        Toast(
          backgroundColor: isOk ? Colors.green : Colors.red,
          message: isOk ? success : error,
          duration: Duration(milliseconds: isOk ? 2000 : 4000),
          isDismissible: false,
        ),
      );

  static void _bottomSheetCount(bool isOpening) {
    if (isOpening) {
      _bottomSheets++;
    } else {
      _bottomSheets--;
    }
    Nav.hasBottomSheet.value = _bottomSheets > 0;
  }

  static void _dialogCount(bool isOpening) {
    if (isOpening) {
      _dialogs++;
    } else {
      _dialogs--;
    }
    Nav.hasDialog.value = _dialogs > 0;
  }

  static void _overlaysCount(bool isOpening) {
    if (isOpening) {
      _overlays++;
    } else {
      _overlays--;
    }
    Nav.hasOverlay.value = _overlays > 0;
  }

  static void _datePickerCount(bool isOpening) {
    if (isOpening) {
      _datePickers++;
    } else {
      _datePickers--;
    }
    Nav.hasDatePicker.value = _datePickers > 0;
  }

  static Future<T?> bottomSheet<T>(
    Widget bottomsheet, {
    Color? backgroundColor,
    double? elevation,
    bool persistent = true,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    bool? ignoreSafeArea,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? settings,
    Duration? enterBottomSheetDuration,
    Duration? exitBottomSheetDuration,
  }) async {
    _bottomSheetCount(true);
    final T? result = await Get.bottomSheet(
      bottomsheet,
      backgroundColor: backgroundColor,
      elevation: elevation,
      persistent: persistent,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      ignoreSafeArea: ignoreSafeArea,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
      enableDrag: enableDrag,
      settings: settings,
      enterBottomSheetDuration: enterBottomSheetDuration,
      exitBottomSheetDuration: exitBottomSheetDuration,
    );
    _bottomSheetCount(false);
    return result;
  }

  static Future<T> loading<T>({
    required Future<T> Function() asyncFunction,
    Color opacityColor = Colors.black,
    Widget loadingWidget = const Center(child: CircularProgressIndicator()),
    double opacity = .5,
  }) async =>
      await overlay<T>(
        asyncFunction: asyncFunction,
        loadingWidget: loadingWidget,
        opacityColor: opacityColor,
        opacity: opacity,
      );

  static Future<T> overlay<T>({
    required Future<T> Function() asyncFunction,
    Color opacityColor = Colors.black,
    Widget? loadingWidget,
    double opacity = .5,
  }) async {
    _overlaysCount(true);
    final T result = await Get.showOverlay(
        asyncFunction: asyncFunction,
        loadingWidget: loadingWidget,
        opacity: opacity);
    _overlaysCount(false);
    return result;
  }

  static Future<T?> modal<T>({
    required String title,
    Widget? content,
    String processText = "Ok",
    String preventText = "Annuler",
    Function()? processAction,
    Function() preventAction = Nav.back,
    RxBool? canProcess,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    GlobalKey<NavigatorState>? navigatorKey,
    Object? arguments,
    Duration? transitionDuration,
    Curve? transitionCurve,
    String? name,
    RouteSettings? routeSettings,
  }) async {
    final canProcessAction = canProcess ?? true.obs;
    return await Show.dialog<T>(
        Dialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0))),
          child: SizedBox(
            width: 200,
            height: content == null ? 110 : 200,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              child: Scaffold(
                appBar: AppBar(
                  leadingWidth: 0,
                  leading: Container(),
                  title: AutoSizeText(
                    title,
                    maxLines: 1,
                  ),
                ),
                body: Material(
                  elevation: 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (content != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20.0, bottom: 10, top: 0),
                          child: SizedBox(height: 45, child: content),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: preventAction,
                              child: Text(preventText)),
                          Obx(
                            () => ElevatedButton(
                                onPressed: canProcessAction.value
                                    ? processAction
                                    : null,
                                child: Text(processText)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        useSafeArea: useSafeArea,
        navigatorKey: navigatorKey,
        arguments: arguments,
        transitionCurve: transitionCurve,
        name: name,
        routeSettings: routeSettings);
  }

  static Future<T?> dialog<T>(
    Widget widget, {
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    GlobalKey<NavigatorState>? navigatorKey,
    Object? arguments,
    Duration? transitionDuration,
    Curve? transitionCurve,
    String? name,
    RouteSettings? routeSettings,
  }) async {
    _dialogCount(true);
    final T? result = await Get.dialog(widget,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        useSafeArea: useSafeArea,
        navigatorKey: navigatorKey,
        arguments: arguments,
        transitionCurve: transitionCurve,
        name: name,
        routeSettings: routeSettings);
    _dialogCount(false);
    return result;
  }

  static Future<DateTimeRange?> dateRangePicker({
    required BuildContext context,
    DateTimeRange? initialDateRange,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    String? helpText,
    String? cancelText,
    String? confirmText,
    String? saveText,
    String? errorFormatText,
    String? errorInvalidText,
    String? errorInvalidRangeText,
    String? fieldStartHintText,
    String? fieldEndHintText,
    String? fieldStartLabelText,
    String? fieldEndLabelText,
    Locale? locale,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TextDirection? textDirection,
    TransitionBuilder? builder,
  }) async {
    _datePickerCount(true);
    final DateTimeRange? date = await dateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      initialEntryMode: initialEntryMode,
      helpText: helpText,
      cancelText: cancelText,
      saveText: saveText,
      errorFormatText: errorFormatText,
      errorInvalidText: errorInvalidText,
      errorInvalidRangeText: errorInvalidRangeText,
      fieldEndHintText: fieldEndHintText,
      fieldEndLabelText: fieldEndLabelText,
      fieldStartHintText: fieldStartHintText,
      fieldStartLabelText: fieldStartLabelText,
      locale: locale,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      textDirection: textDirection,
      builder: builder,
    );
    _datePickerCount(false);
    return date;
  }
}
