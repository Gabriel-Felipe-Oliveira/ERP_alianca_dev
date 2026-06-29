import 'dart:io';

import 'package:flutter/material.dart';

/// Camada extra: exclui subárvore da ponte de acessibilidade no Windows.
/// A desativação principal está em [ErpWidgetsFlutterBinding].
class WindowsSemanticsGuard extends StatelessWidget {  const WindowsSemanticsGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return ExcludeSemantics(child: child);
    }
    return child;
  }
}
