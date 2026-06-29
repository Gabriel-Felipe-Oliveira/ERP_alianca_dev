import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

/// Mitiga dessincronia do teclado no Flutter Windows (backspace/enter travados).
abstract final class WindowsKeyboardFix {
  static WindowListener? _listener;

  static Future<void> install() async {
    if (!Platform.isWindows) return;

    _listener ??= _WindowsKeyboardListener();
    windowManager.addListener(_listener!);

    WidgetsBinding.instance.addPostFrameCallback((_) => syncNow());
  }

  static void syncNow() {
    if (!Platform.isWindows) return;
    try {
      HardwareKeyboard.instance.syncKeyboardState();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WindowsKeyboardFix: sync falhou: $e');
      }
    }
  }

  static void uninstall() {
    final listener = _listener;
    if (listener != null) {
      windowManager.removeListener(listener);
      _listener = null;
    }
  }
}

final class _WindowsKeyboardListener with WindowListener {
  @override
  void onWindowFocus() {
    WindowsKeyboardFix.syncNow();
  }
}
