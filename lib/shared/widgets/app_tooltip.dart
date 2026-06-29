import 'dart:io';

import 'package:flutter/material.dart';

/// Tooltip seguro no Windows: o [Tooltip] do framework insere overlay na
/// árvore de semântica e dispara erros `AXTree` no engine desktop.
class AppTooltip extends StatelessWidget {
  const AppTooltip({
    super.key,
    required this.message,
    required this.child,
    this.waitDuration,
    this.preferBelow,
  });

  final String message;
  final Widget child;
  final Duration? waitDuration;
  final bool? preferBelow;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return child;
    }
    return Tooltip(
      message: message,
      waitDuration: waitDuration,
      preferBelow: preferBelow,
      child: child,
    );
  }
}

/// Para [IconButton.tooltip] e similares — no Windows retorna `null`.
String? windowsSafeTooltip(String? message) {
  if (Platform.isWindows) return null;
  return message;
}
