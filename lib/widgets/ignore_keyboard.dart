import 'package:flutter/material.dart';

import '../statics/keyboard.dart';

class IgnoreKeyboard extends StatelessWidget {
  final Widget? child;

  const IgnoreKeyboard({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (_) {
        Keyboard.closable = false;
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
