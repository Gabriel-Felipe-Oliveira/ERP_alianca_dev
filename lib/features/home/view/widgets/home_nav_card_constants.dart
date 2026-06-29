import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Tamanhos fixos dos atalhos quadrados na Home.
abstract final class HomeNavCardConstants {
  static const double cardSize = 176;
  static const double cardRadius = 20;
  static const double padding = 16;
  static const double iconSize = 44;
  static const double spaceBelowIcon = 8;
  static const double labelFontSize = 18;
  static const double cardGap = 16;
  static const double columnGap = 48;
  static const double rowGap = 40;

  /// Largura de uma célula da grade (até 2 cards lado a lado).
  static double get sectionWidth => cardSize * 2 + cardGap;

  static TextStyle get labelStyle => TextStyle(
        fontSize: labelFontSize,
        fontWeight: FontWeight.w600,
        height: 1.15,
        color: AppColors.textTitle,
      );
}
