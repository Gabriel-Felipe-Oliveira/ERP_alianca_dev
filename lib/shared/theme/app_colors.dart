import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/models/empresa_palette_model.dart';

/// Cores e branding (Design System). Todas as telas usam apenas daqui.
abstract class AppColors {
  static EmpresaPalette? _current;

  static void setCurrent(EmpresaPalette palette) {
    _current = palette;
  }

  static EmpresaPalette get _palette => _current!;

  static bool get isLightTheme => _palette.isLightTheme;

  static Color get background => _palette.background;
  static Color get contentBackground => _palette.contentBackground;
  static Color get sidebarItemBackground => _palette.sidebarItemBackground;
  static Color get card => _palette.card;
  static Color get cardBorder => _palette.cardBorder;
  static Color get cardShadowColor => _palette.cardShadowColor;
  static List<BoxShadow> get cardBoxShadow => _palette.cardBoxShadow;
  static Color get cardHoverBackground => _palette.cardHoverBackground;
  static Color get input => _palette.input;
  static Color get inputEnabledBorder => _palette.inputEnabledBorder;
  static Color get primary => _palette.primary;
  static Color get primaryHover => _palette.primaryHover;
  static Color get primaryLight => _palette.primaryLight;
  static Color get textPrimary => _palette.textPrimary;
  static Color get textTitle => _palette.textTitle;
  static Color get textBody => _palette.textBody;
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
  static Color get secondaryButtonHoverBackground =>
      _palette.secondaryButtonHoverBackground;
  static Color get listagemSearchBarBackground =>
      _palette.listagemSearchBarBackground;
  static Color get listagemSearchBarHover => _palette.listagemSearchBarHover;
  static Color get listagemItemHover => _palette.listagemItemHover;
  static Color get listagemItemSelectedBackground =>
      _palette.listagemItemSelectedBackground;
  static Color get listagemItemSelectedBorder =>
      _palette.listagemItemSelectedBorder;
  static Color get listagemHeaderGradientStart =>
      _palette.listagemHeaderGradientStart;
  static Color get listagemHeaderGradientEnd =>
      _palette.listagemHeaderGradientEnd;
  static Color get listagemItemBackground => _palette.listagemItemBackground;
  static Color get panelBackground => _palette.panelBackground;
  static Color get sidebarMenuActiveBackground =>
      _palette.sidebarMenuActiveBackground;
  static Color get sidebarMenuActiveText => _palette.sidebarMenuActiveText;
  static Color get sidebarMenuActiveIcon => _palette.sidebarMenuActiveIcon;
  static Color get sidebarMenuHoverBackground =>
      _palette.sidebarMenuHoverBackground;

  static Color get sidebarBackground => _palette.sidebarBackground;
  static Color get sidebarDivider => _palette.sidebarDivider;
  static Color get sidebarBorder => _palette.sidebarBorder;
  static Color get sidebarTextActive => _palette.sidebarTextActive;
  static Color get sidebarTextMuted => _palette.sidebarTextMuted;
  static Color get sidebarTextHover => _palette.sidebarTextHover;
  static Color get surface => _palette.surface;
  static Color get divider => _palette.divider;

  static String? get logoPath => _palette.logoPath;
}
