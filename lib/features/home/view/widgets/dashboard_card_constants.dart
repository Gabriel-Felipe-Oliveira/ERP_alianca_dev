import 'package:flutter/material.dart';

/// Constantes visuais e de layout do [DashboardCard].
class DashboardCardConstants {
  DashboardCardConstants._();

  static const double cardRadius = 18;
  static const double minWidth = 120;
  static const double minHeight = 100;
  static const double padding = 28;
  static const double iconSize = 30;
  static const double spaceBelowIcon = 12;

  /// Altura fixa da área do título (para ele não se deslocar quando o valor escala).
  static const double titleAreaHeight = 44;

  /// Abaixo desse tamanho (área interna do card), mostra só o ícone centralizado.
  static const double minWidthForFullContent = 140;
  static const double minHeightForFullContent = 80;
  static const double hoverScale = 1.03;
  static const Duration hoverDuration = Duration(milliseconds: 200);

  static BoxDecoration get decoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(
          color: Colors.grey.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      );

  static const TextStyle totalTextStyle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );
}
