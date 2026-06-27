import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Constantes visuais e de layout do [DashboardCard].
class DashboardCardConstants {
  DashboardCardConstants._();

  static const double cardRadius = 16;
  static const double minWidth = 120;
  static const double minHeight = 100;
  static const double padding = 24;
  static const double iconSize = 30;
  static const double spaceBelowIcon = 12;
  static const double titleAreaHeight = 44;
  static const double minWidthForFullContent = 140;
  static const double minHeightForFullContent = 80;
  static const double hoverScale = 1.01;
  static const Duration hoverDuration = Duration(milliseconds: 200);

  static BoxDecoration decoration({bool hovering = false}) => BoxDecoration(
        color: hovering && AppColors.isLightTheme
            ? AppColors.cardHoverBackground
            : AppColors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: AppColors.cardBoxShadow,
      );

  static TextStyle get totalTextStyle => TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: AppColors.textTitle,
      );

  static TextStyle get titleTextStyle => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );
}
