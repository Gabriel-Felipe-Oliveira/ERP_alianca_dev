import 'package:flutter/material.dart';

/// Paleta de cores e branding por empresa. Permite customizar tema e logo por cliente (id_empresa).
/// Você passa apenas as cores base; as demais são derivadas (opacidade/lerp).
/// No modo claro ([isLightTheme]), cores fixas seguem o design system premium (Linear/Stripe).
class EmpresaPalette {
  /// Fundo da área de conteúdo (telas, listagens). Variável independente da sidebar.
  final Color background;

  /// Fundo da sidebar (lateral). Variável independente do background.
  final Color sidebarBackground;
  final Color primary;
  final Color textPrimary;
  final Color error;
  final Color success;
  final Color toolPanelItemDangerBackground;
  final Color toolPanelItemLightBackground;
  final Color toolPanelItemDarkBackground;
  final bool isLightTheme;

  /// Caminho do asset do logo (ex: "assets/logos/empresa_1.png"). Se null, use ícone padrão.
  final String? logoPath;

  const EmpresaPalette({
    required this.background,
    required this.sidebarBackground,
    required this.primary,
    required this.textPrimary,
    required this.error,
    required this.success,
    required this.toolPanelItemDangerBackground,
    required this.toolPanelItemLightBackground,
    required this.toolPanelItemDarkBackground,
    this.isLightTheme = false,
    this.logoPath,
  });

  // --- Tokens fixos do tema claro ---
  static const Color _lightStructuralBorder = Color(0xFFE5E7EB);
  static const Color _lightInputBorder = Color(0xFFD1D5DB);
  static const Color _lightTextTitle = Color(0xFF111827);
  static const Color _lightTextBody = Color(0xFF374151);
  static const Color _lightTextSecondary = Color(0xFF6B7280);
  static const Color _lightPrimary = Color(0xFF2563EB);
  static const Color _lightPrimaryHover = Color(0xFF1D4ED8);
  static const Color _lightMenuActiveBg = Color(0xFFDBEAFE);
  static const Color _lightMenuActiveText = Color(0xFF1D4ED8);
  static const Color _lightMenuHoverBg = Color(0xFFEFF6FF);
  static const Color _lightListHover = Color(0xFFF9FAFB);
  static const Color _lightListSelectedBg = Color(0xFFEFF6FF);
  static const Color _lightListSelectedBorder = Color(0xFF93C5FD);
  static const Color _lightCardHover = Color(0xFFFAFAFA);
  static const Color _lightSecondaryButtonHover = Color(0xFFF3F4F6);

  Color get contentBackground => background;

  Color get textTitle =>
      isLightTheme ? _lightTextTitle : textPrimary;

  Color get textBody =>
      isLightTheme ? _lightTextBody : textPrimary;

  Color get primaryHover =>
      isLightTheme ? _lightPrimaryHover : primaryLight;

  Color get sidebarMenuActiveBackground =>
      isLightTheme ? _lightMenuActiveBg : listagemItemHover.withValues(alpha: 0.42);

  Color get sidebarMenuActiveText =>
      isLightTheme ? _lightMenuActiveText : sidebarTextActive;

  Color get sidebarMenuActiveIcon =>
      isLightTheme ? _lightPrimary : sidebarTextActive;

  Color get sidebarMenuHoverBackground =>
      isLightTheme ? _lightMenuHoverBg : listagemItemHover.withValues(alpha: 0.28);

  Color get listagemItemSelectedBackground =>
      isLightTheme ? _lightListSelectedBg : listagemItemHover.withValues(alpha: 0.35);

  Color get listagemItemSelectedBorder =>
      isLightTheme ? _lightListSelectedBorder : primary;

  Color get cardHoverBackground =>
      isLightTheme ? _lightCardHover : listagemItemHover;

  Color get secondaryButtonHoverBackground =>
      isLightTheme ? _lightSecondaryButtonHover : actionBarHover;

  Color get panelBackground =>
      isLightTheme ? card : sidebarBackground;

  // --- Área de conteúdo (tema escuro: derivadas por lerp) ---
  Color get sidebarItemBackground => isLightTheme
      ? const Color(0xFFF3F4F6)
      : Color.lerp(sidebarBackground, Colors.white, 0.10)!;

  Color get card => isLightTheme
      ? Colors.white
      : Color.lerp(background, Colors.white, 0.08)!;

  Color get input => isLightTheme ? Colors.white : Color.lerp(background, Colors.white, 0.12)!;

  Color get actionBarBackground => isLightTheme
      ? Colors.white
      : Color.lerp(background, Colors.white, 0.06)!;

  Color get actionBarHover => isLightTheme
      ? _lightSecondaryButtonHover
      : Color.lerp(background, Colors.white, 0.14)!;

  Color get listagemSearchBarBackground => isLightTheme
      ? Colors.white
      : Color.lerp(background, Colors.white, 0.02)!;

  Color get listagemSearchBarHover => isLightTheme
      ? _lightListHover
      : Color.lerp(background, Colors.white, 0.06)!;

  Color get listagemItemBackground =>
      isLightTheme ? Colors.white : sidebarBackground;

  Color get listagemItemHover =>
      isLightTheme ? _lightListHover : Color.lerp(sidebarBackground, Colors.white, 0.12)!;

  Color get listagemHeaderGradientStart => contentBackground;
  Color get listagemHeaderGradientEnd => background;

  Color get cardBorder =>
      isLightTheme ? _lightStructuralBorder : textPrimary.withValues(alpha: 0.05);

  Color get inputEnabledBorder =>
      isLightTheme ? _lightInputBorder : textPrimary.withValues(alpha: 0.08);

  Color get border =>
      isLightTheme ? _lightStructuralBorder : textPrimary.withValues(alpha: 0.1);

  Color get textSecondary => isLightTheme
      ? _lightTextSecondary
      : textPrimary.withValues(alpha: 0.7);

  Color get primaryLight => isLightTheme
      ? _lightPrimaryHover
      : Color.lerp(primary, textPrimary, 0.5)!;

  Color get cardShadowColor =>
      isLightTheme ? const Color(0x0A000000) : const Color(0x40000000);

  List<BoxShadow> get cardBoxShadow => isLightTheme
      ? const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ]
      : [
          BoxShadow(
            color: cardShadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ];

  /// Cores usadas pelo AppTheme e sidebar (derivadas de [sidebarBackground]).
  Color get sidebarDivider =>
      isLightTheme ? _lightStructuralBorder : sidebarItemBackground;

  Color get sidebarBorder => isLightTheme ? _lightStructuralBorder : border;

  Color get sidebarTextMuted => textSecondary;

  Color get sidebarTextActive =>
      isLightTheme ? _lightTextBody : textPrimary;

  Color get sidebarTextHover => isLightTheme
      ? _lightPrimary
      : Color.lerp(primary, Colors.white, 0.6)!;

  Color get surface => card;
  Color get divider => border;

  /// Variante clara da paleta — design system premium (Linear / Stripe / Notion).
  factory EmpresaPalette.lightFrom(EmpresaPalette base) {
    return EmpresaPalette(
      background: const Color(0xFFF5F7FA),
      sidebarBackground: const Color(0xFFF8FAFC),
      primary: _lightPrimary,
      textPrimary: _lightTextTitle,
      error: base.error,
      success: base.success,
      toolPanelItemDangerBackground: const Color(0xFFFEE2E2),
      toolPanelItemLightBackground: const Color(0xFFF8FAFC),
      toolPanelItemDarkBackground: const Color(0xFFE5E7EB),
      isLightTheme: true,
      logoPath: base.logoPath,
    );
  }

  /// Converte hex string (ex: "0xFF3B82F6") ou int para Color.
  static Color _colorFromJson(dynamic value) {
    if (value == null) return const Color(0xFF000000);
    if (value is int) return Color(value);
    final s = value.toString().trim();
    if (s.startsWith('0x')) return Color(int.parse(s.substring(2), radix: 16));
    return Color(int.parse(s, radix: 16));
  }

  factory EmpresaPalette.fromJson(Map<String, dynamic> json) {
    return EmpresaPalette(
      background: _colorFromJson(json['background']),
      sidebarBackground: _colorFromJson(json['sidebar_background'] ?? json['background']),
      primary: _colorFromJson(json['primary']),
      textPrimary: _colorFromJson(json['text_primary']),
      error: _colorFromJson(json['error']),
      success: _colorFromJson(json['success']),
      toolPanelItemDangerBackground:
          _colorFromJson(json['tool_panel_item_danger_background']),
      toolPanelItemLightBackground:
          _colorFromJson(json['tool_panel_item_light_background']),
      toolPanelItemDarkBackground:
          _colorFromJson(json['tool_panel_item_dark_background']),
      logoPath: json['logo_path'] as String?,
    );
  }

  static int _colorToJson(Color c) => c.toARGB32();

  Map<String, dynamic> toJson() => {
        'background': _colorToJson(background),
        'sidebar_background': _colorToJson(sidebarBackground),
        'primary': _colorToJson(primary),
        'text_primary': _colorToJson(textPrimary),
        'error': _colorToJson(error),
        'success': _colorToJson(success),
        'tool_panel_item_danger_background':
            _colorToJson(toolPanelItemDangerBackground),
        'tool_panel_item_light_background':
            _colorToJson(toolPanelItemLightBackground),
        'tool_panel_item_dark_background':
            _colorToJson(toolPanelItemDarkBackground),
        'logo_path': logoPath,
      };
}
