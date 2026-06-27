import 'package:flutter/material.dart';

/// Constantes do menu lateral (sidebar).
/// Centraliza dimensões e espaçamentos para manutenção fácil.
class SidebarConstants {
  SidebarConstants._();

  /// Largura expandida (Figma: 256px)
  static const double sidebarExpandedWidth = 256;

  /// Largura recolhida (somente ícones)
  static const double sidebarCollapsedWidth = 72;

  /// Largura abaixo da qual o conteúdo compacto é exibido durante a animação.
  static const double compactLayoutBreakpoint = 164;

  /// Duração da animação de recolher/expandir a sidebar
  static const Duration sidebarCollapseDuration = Duration(milliseconds: 280);

  /// Margem inferior entre itens do menu (+ espaçamento extra)
  static const double menuItemMarginBottom = 14;

  /// Padding horizontal do conteúdo dos itens
  static const double itemContentPaddingHorizontal = 12;

  /// Padding vertical do conteúdo dos itens principais
  static const double itemContentPaddingVertical = 4;

  /// Padding horizontal dos subitens
  static const double subItemPaddingHorizontal = 8;

  /// Padding entre item principal e subseções expandidas
  static const EdgeInsets subSectionsPadding = EdgeInsets.only(
    left: 12,
    right: 12,
    top: 12,
    bottom: 4,
  );

  // --- Conectores |_ ---

  /// Espaço à esquerda da linha vertical
  static const double connectorSpace = 4;

  /// Espessura da linha vertical |
  static const double connectorVerticalWidth = 2;

  /// Espessura da linha horizontal _
  static const double connectorHorizontalHeight = 2;

  /// Largura da linha horizontal _
  static const double connectorHorizontalWidth = 10;

  /// Espaço entre subitens
  static const double connectorGap = 4;

  /// Altura de cada linha de subitem
  static const double connectorRowHeight = 26;

  // --- Animação ---

  /// Duração da animação de expandir/colapsar subseções
  static const Duration expandAnimationDuration = Duration(milliseconds: 700);

  /// Curva da animação de expandir/colapsar
  static const Curve expandAnimationCurve = Curves.easeOutCubic;

  /// Duração da transição do conteúdo da tela (mais longa para suavidade)
  static const Duration contentTransitionDuration = Duration(milliseconds: 900);

  /// Curva da transição do conteúdo (easeInOut = início e fim suaves)
  static const Curve contentTransitionCurve = Curves.easeInOutCubic;
}
