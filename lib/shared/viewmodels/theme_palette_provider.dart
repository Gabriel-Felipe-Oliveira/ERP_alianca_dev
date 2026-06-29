import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/core/theme/app_theme.dart';
import 'package:erp_alianca_dev/core/theme/empresa_palettes.dart';
import 'package:erp_alianca_dev/shared/models/empresa_palette_model.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/local_storage_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/viewmodels/app_router_refresh_notifier.dart';

/// Provider que expõe paleta + modo claro/escuro para o MaterialApp.
class ThemePaletteProvider extends ChangeNotifier {
  ThemePaletteProvider(
    this._empresaService,
    this._localStorage,
  ) {
    _basePalette = EmpresaPalettes.getById(_empresaService.idEmpresa);
    _isLightMode =
        _localStorage.getBool(LocalStorageService.themeLightModeKey) ?? false;
    _applyPalette();
    _empresaService.addListener(_onEmpresaChanged);
  }

  final EmpresaService _empresaService;
  final LocalStorageService _localStorage;
  bool _disposed = false;
  late EmpresaPalette _basePalette;
  late bool _isLightMode;

  bool get isLightMode => _isLightMode;

  ThemeMode get themeMode =>
      _isLightMode ? ThemeMode.light : ThemeMode.dark;

  EmpresaPalette get currentPalette => _isLightMode
      ? EmpresaPalette.lightFrom(_basePalette)
      : _basePalette;

  ThemeData get lightThemeData =>
      AppTheme.lightFromPalette(EmpresaPalette.lightFrom(_basePalette));

  ThemeData get darkThemeData => AppTheme.darkFromPalette(_basePalette);

  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  void _notifyThemeChanged() {
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      AppRouterRefreshNotifier.instance.notifyListeners();
    });
  }

  Future<void> toggleThemeMode() => setLightMode(!_isLightMode);

  Future<void> setLightMode(bool value) async {
    if (_isLightMode == value) return;
    _isLightMode = value;
    _applyPalette();
    _notifyThemeChanged();
    await _localStorage.setBool(
      LocalStorageService.themeLightModeKey,
      value: value,
    );
  }

  void _onEmpresaChanged() {
    _basePalette = EmpresaPalettes.getById(_empresaService.idEmpresa);
    _applyPalette();
    _notifyThemeChanged();
  }

  void _applyPalette() {
    AppColors.setCurrent(currentPalette);
  }

  @override
  void dispose() {
    _disposed = true;
    _empresaService.removeListener(_onEmpresaChanged);
    super.dispose();
  }
}
