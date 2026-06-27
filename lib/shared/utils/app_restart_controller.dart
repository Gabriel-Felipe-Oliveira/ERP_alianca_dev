import 'package:flutter/foundation.dart';

/// Controlador para reinício completo do app.
///
/// Ao chamar [restart], o app exibe o overlay azul com loading,
/// depois reconstrói a árvore (perde rotas e volta para a Home).
class AppRestartController {
  AppRestartController(this._onRestart);

  final VoidCallback _onRestart;

  /// Invoca o reinício: mostra overlay, depois reconstrói o app.
  void restartApp() => _onRestart();
}
