import 'package:flutter/material.dart';

import '../services/responsive_service.dart';
import '../statics/dep.dart';
import '../statics/keyboard.dart';

class Responsive extends StatefulWidget {
  final Widget? child;

  const Responsive(this.child, {Key? key}) : super(key: key);

  @override
  _ResponsiveState createState() => _ResponsiveState();
}

class _ResponsiveState extends State<Responsive> with WidgetsBindingObserver {
  final ResponsiveService _service = Dep.find<ResponsiveService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
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
    _service.screenChanged();
    _service.handleKeyboard();
  }
}
