import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/widgets/app_palette_scope.dart';

/// Propaga rebuild quando o modo claro/escuro muda, sem trocar a key da subárvore.
class AppThemeRebuildChild extends StatelessWidget {
  const AppThemeRebuildChild({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    AppPaletteScope.of(context);
    return child;
  }
}
