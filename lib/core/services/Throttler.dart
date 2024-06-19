import 'dart:async';
import 'package:flutter/widgets.dart';

class Throttler {
  final int seconds;
  bool _isReady = true;
  VoidCallback? _lastAction;

  Throttler({required this.seconds});

  void run(VoidCallback action) {
    if (_isReady) {
      action();
      _isReady = false;
      Timer(Duration(seconds: seconds), () {
        _isReady = true;
        if (_lastAction != null) {
          run(_lastAction!);
          _lastAction = null;
        }
      });
    } else {
      _lastAction = action;
    }
  }

  void dispose() {
    _lastAction = null;
    _isReady = true;
  }
}