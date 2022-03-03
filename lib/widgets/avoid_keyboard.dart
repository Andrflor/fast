import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/typedef.dart';

class AvoidKeyboard extends StatefulWidget {
  /// The child to wrap.
  final Widget child;

  /// The space between the active input control and the top of the keyboard.
  /// Must be >= 0.
  final double? spacing;

  const AvoidKeyboard({
    Key? key,
    required this.child,
    this.spacing,
  }) : super(key: key);

  @override
  _AvoidKeyboardState createState() => _AvoidKeyboardState();
}

class _AvoidKeyboardState extends State<AvoidKeyboard> {
  final _focusNode = FocusNode();
  final _scroll = ScrollController();

  double _offset = 0;

  bool _hasFocus = false;

  double get _spacing => (widget.spacing ?? 0) < 0 ? 0 : widget.spacing ?? 0;

  void afterFirstLayout() {
    _focusNode.addListener(() async {
      if (!_focusNode.hasFocus) {
        _handleLoseFocus();
      }
    });

    for (final node in _focusNode.traversalDescendants) {
      node.addListener(() {
        if (node.hasFocus) {
          _handleFocus();
        }
      });
    }
  }

  @override
  void initState() {
    runAfterBuild(afterFirstLayout);
    super.initState();
  }

  void _handleFocus() async {
    FocusNode primaryNode;

    try {
      primaryNode = _focusNode.traversalDescendants
          .firstWhere((element) => element.hasPrimaryFocus);
    } catch (_) {
      return;
    }

    try {
      // Wait for the bottom inset to update, unless another
      // child node has already been focused.
      if (!_hasFocus) {
        await waitForKeyboardFrameUpdate();
      } else {
        await Future.delayed(const Duration(milliseconds: 50))
            .catchError((_) {});
      }
    } catch (_) {
      // Catch possible timeout error
    }

    final viewPortBottom = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom -
        _spacing;
    final nodeBottom = primaryNode.rect.bottom;

    if (nodeBottom > viewPortBottom) {
      final overlap = nodeBottom - viewPortBottom;

      setState(() {
        _offset += overlap;
        _scroll.jumpTo(_offset);
        _hasFocus = true;
      });
    }
  }

  // The keyboard frame will not update immediately upon focus, therefore
  // we need to see a change in the bottom inset, before scrolling the viewport.
  Future<void> waitForKeyboardFrameUpdate() {
    final completer = Completer();
    final currentBottomInset = MediaQuery.of(context).viewInsets.bottom;

    final timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final newBottomInset = MediaQuery.of(context).viewInsets.bottom;

      if (currentBottomInset != newBottomInset) {
        completer.complete();
      }
    });

    return completer.future
        .timeout(const Duration(milliseconds: 100))
        .whenComplete(() => timer.cancel());
  }

  void _handleLoseFocus() async {
    setState(() {
      _offset = 0;
      _scroll.jumpTo(_offset);
      _hasFocus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: SingleChildScrollView(
        controller: _scroll,
        physics:
            const ClampingScrollPhysics(parent: NeverScrollableScrollPhysics()),
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: widget.child),
      ),
    );
  }
}
