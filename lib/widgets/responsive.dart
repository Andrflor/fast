import 'package:flutter/material.dart';

import '../services/responsive_service.dart';
import '../statics/keyboard.dart';

class Responsive extends StatefulWidget {
  final Widget? child;

  const Responsive(this.child, {Key? key}) : super(key: key);

  @override
  _ResponsiveState createState() => _ResponsiveState();
}

class _ResponsiveState extends State<Responsive> with WidgetsBindingObserver {
  final _responsiveService = ResponsiveService();

  @override
  void initState() {
    super.initState();
    _responsiveService.screenChanged();
    _responsiveService.notify();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (_) {
        Future.delayed(Duration.zero, Keyboard.close);
      },
      behavior: HitTestBehavior.translucent,
      child: widget.child!,
    );
  }

  @override
  void didChangeMetrics() {
    _responsiveService.screenChanged();
    _responsiveService.handleKeyboard();
  }
}
