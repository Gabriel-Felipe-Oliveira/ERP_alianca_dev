import 'package:flutter/material.dart';

/// Cores usadas apenas pelo tema claro ([AppTheme.light]).
/// Cores por empresa (tema escuro) ficam em [core/theme/empresa_palettes.dart].
abstract class AppColors {
  // Primárias
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Secundárias
  static const Color secondary = Color(0xFF26A69A);
  static const Color secondaryDark = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFF80CBC4);

  // Neutras
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // --- Dark theme (Figma Sidebar Dashboard) ---
  /// Fundo da sidebar (slate escuro)
  static const Color sidebarBackground = Color(0xFF0F172A);
  /// Fundo da área de conteúdo (tom refinado)
  static const Color contentBackground = Color(0xFF1E293B);
  /// Divisor e fundo do item selecionado na sidebar
  static const Color sidebarDivider = Color(0xFF2D2F39);
  /// Borda direita da sidebar - rgba(255,255,255,0.1)
  static const Color sidebarBorder = Color(0x1AFFFFFF);
  /// Texto sidebar (inativo) - rgba(255,255,255,0.5)
  static const Color sidebarTextMuted = Color(0x80FFFFFF);
  /// Texto sidebar (ativo) - rgba(255,255,255,0.8)
  static const Color sidebarTextActive = Color(0xCCFFFFFF);
  /// Texto sidebar (hover) - azul claro, não tão claro
  static const Color sidebarTextHover = Color(0xFF5BA3E8);
  /// Cor destaque logout
  static const Color sidebarLogout = Color(0xFFCC8889);
}
