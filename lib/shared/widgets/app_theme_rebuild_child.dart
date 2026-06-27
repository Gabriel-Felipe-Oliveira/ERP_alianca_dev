import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/shared/viewmodels/theme_palette_provider.dart';

/// Força rebuild de [child] quando o modo claro/escuro muda.
/// Necessário porque a UI usa [AppColors] estático e o GoRouter preserva páginas.
class AppThemeRebuildChild extends StatelessWidget {
  const AppThemeRebuildChild({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<ThemePaletteProvider>().isLightMode;
    return KeyedSubtree(
      key: ValueKey<bool>(isLight),
      child: child,
    );
  }
}
