import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/core/theme/app_theme.dart';
import 'package:erp_alianca_dev/core/theme/empresa_palettes.dart';
import 'package:erp_alianca_dev/shared/models/empresa_palette_model.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';

/// Provider que expõe a paleta já definida no main (via EmpresaPalettes.getById) para o MaterialApp.
/// AppColors.setCurrent é feito no main.dart antes do runApp.
class ThemePaletteProvider extends ChangeNotifier {
  ThemePaletteProvider(this._empresaService) {
    _palette = EmpresaPalettes.getById(_empresaService.idEmpresa);
    _empresaService.addListener(_onEmpresaChanged);
  }

  final EmpresaService _empresaService;
  bool _disposed = false;
  late EmpresaPalette _palette;

  void _onEmpresaChanged() {
    _palette = EmpresaPalettes.getById(_empresaService.idEmpresa);
    notifyListeners();
  }

  EmpresaPalette get currentPalette => _palette;

  /// Tema escuro construído a partir da paleta da empresa (para MaterialApp).
  ThemeData get themeData => AppTheme.darkFromPalette(_palette);

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _empresaService.removeListener(_onEmpresaChanged);
    super.dispose();
  }
}
