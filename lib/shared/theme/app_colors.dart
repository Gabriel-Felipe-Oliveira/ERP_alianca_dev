import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/models/empresa_palette_model.dart';

/// Cores e branding (logo) do Design System. Todas as telas usam apenas daqui.
/// Paleta atual vem do main ([setCurrent] com [EmpresaPalettes.getById]). Sempre há uma empresa; sem fallback.
/// Todas as paletas por empresa ficam em um único lugar: [core/theme/empresa_palettes.dart].
abstract class AppColors {
  static EmpresaPalette? _current;

  /// Define a paleta da empresa atual. Chamado no main antes do runApp (sempre chamado).
  static void setCurrent(EmpresaPalette palette) {
    _current = palette;
  }

  static EmpresaPalette get _palette => _current!;

  static Color get background => _palette.background;
  static Color get contentBackground => _palette.contentBackground;
  static Color get sidebarItemBackground => _palette.sidebarItemBackground;
  static Color get card => _palette.card;
  static Color get cardBorder => _palette.cardBorder;
  static Color get cardShadowColor => EmpresaPalette.cardShadowColor;
  static Color get input => _palette.input;
  static Color get inputEnabledBorder => _palette.inputEnabledBorder;
  static Color get primary => _palette.primary;
  static Color get primaryLight => _palette.primaryLight;
  static Color get textPrimary => _palette.textPrimary;
  static Color get textSecondary => _palette.textSecondary;
  static Color get border => _palette.border;
  static Color get error => _palette.error;
  static Color get toolPanelItemDangerBackground =>
      _palette.toolPanelItemDangerBackground;
  static Color get success => _palette.success;
  static Color get toolPanelItemLightBackground =>
      _palette.toolPanelItemLightBackground;
  static Color get toolPanelItemDarkBackground =>
      _palette.toolPanelItemDarkBackground;
  static Color get actionBarBackground => _palette.actionBarBackground;
  static Color get actionBarHover => _palette.actionBarHover;
  static Color get listagemSearchBarBackground =>
      _palette.listagemSearchBarBackground;
  static Color get listagemSearchBarHover => _palette.listagemSearchBarHover;
  static Color get listagemItemHover => _palette.listagemItemHover;
  static Color get listagemHeaderGradientStart =>
      _palette.listagemHeaderGradientStart;
  static Color get listagemHeaderGradientEnd =>
      _palette.listagemHeaderGradientEnd;
  static Color get listagemItemBackground => _palette.listagemItemBackground;

  /// Sidebar (alias da paleta).
  static Color get sidebarBackground => _palette.sidebarBackground;
  static Color get sidebarDivider => _palette.sidebarDivider;
  static Color get sidebarBorder => _palette.sidebarBorder;
  static Color get sidebarTextActive => _palette.sidebarTextActive;
  static Color get sidebarTextMuted => _palette.sidebarTextMuted;
  static Color get sidebarTextHover => _palette.sidebarTextHover;
  static Color get surface => _palette.surface;
  static Color get divider => _palette.divider;

  /// Caminho do asset do logo da empresa (ex: "assets/logos/empresa_1.png"). Null = use ícone padrão.
  static String? get logoPath => _palette.logoPath;
}
