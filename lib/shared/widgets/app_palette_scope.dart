import 'package:flutter/material.dart';

/// Expõe mudanças de paleta para widgets que usam [AppColors] estático.
/// Preferir [of] em vez de [KeyedSubtree] — evita corrupção do AXTree no Windows.
class AppPaletteScope extends InheritedWidget {
  const AppPaletteScope({
    super.key,
    required this.isLightMode,
    required super.child,
  });

  final bool isLightMode;

  static AppPaletteScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppPaletteScope>();
    assert(scope != null, 'AppPaletteScope não encontrado na árvore.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppPaletteScope oldWidget) =>
      isLightMode != oldWidget.isLightMode;
}
