import 'package:flutter/material.dart';

/// Paleta de cores e branding por empresa. Permite customizar tema e logo por cliente (id_empresa).
/// Você passa apenas as cores base; as demais são derivadas (opacidade/lerp).
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
    this.logoPath,
  });

  // --- Área de conteúdo: usa o valor da paleta (0xFF1E293B), sem lerp, para manter as cores originais.
  Color get contentBackground => background;
  // --- Derivadas da sidebar ---
  Color get sidebarItemBackground => Color.lerp(sidebarBackground, Colors.white, 0.10)!;
  Color get card => Color.lerp(background, Colors.white, 0.08)!;
  Color get input => Color.lerp(background, Colors.white, 0.12)!;
  Color get actionBarBackground => Color.lerp(background, Colors.white, 0.06)!;
  Color get actionBarHover => Color.lerp(background, Colors.white, 0.14)!;
  Color get listagemSearchBarBackground =>
      Color.lerp(background, Colors.white, 0.02)!;
  Color get listagemSearchBarHover => Color.lerp(background, Colors.white, 0.06)!;
  /// Fundo do item de listagem (clientes, produtos, etc.) — mesma cor da sidebar.
  Color get listagemItemBackground => sidebarBackground;
  Color get listagemItemHover => Color.lerp(sidebarBackground, Colors.white, 0.12)!;
  Color get listagemHeaderGradientStart => contentBackground;
  Color get listagemHeaderGradientEnd => background;

  // --- Derivadas do textPrimary (branco) com opacidade ---
  Color get cardBorder => textPrimary.withValues(alpha: 0.05);
  Color get inputEnabledBorder => textPrimary.withValues(alpha: 0.08);
  Color get border => textPrimary.withValues(alpha: 0.1);
  Color get textSecondary => textPrimary.withValues(alpha: 0.7);

  // --- Derivada do primary ---
  Color get primaryLight => Color.lerp(primary, textPrimary, 0.5)!;

  // --- Fixas (preto com opacidade) ---
  static const Color cardShadowColor = Color(0x40000000);

  /// Cores usadas pelo AppTheme e sidebar (derivadas de [sidebarBackground]).
  Color get sidebarDivider => sidebarItemBackground;
  Color get sidebarBorder => border;
  Color get sidebarTextMuted => textSecondary;
  Color get sidebarTextActive => textPrimary;
  Color get sidebarTextHover => Color.lerp(primary, Colors.white, 0.6)!;
  Color get surface => card;
  Color get divider => border;

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
