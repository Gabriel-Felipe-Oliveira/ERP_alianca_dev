import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Estilos de texto do Design System. Usar apenas essas definições.
abstract class AppTextStyles {
  static TextStyle get heading1 => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textTitle,
      );

  static TextStyle get heading2 => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textTitle,
      );

  static TextStyle get pageHeaderTitle => TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: AppColors.textTitle,
      );

  static TextStyle get pageHeaderDescription => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get heading3 => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textTitle,
      );

  static TextStyle get sectionTitle => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textTitle,
      );

  static TextStyle get sectionTitleSecondary => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textTitle,
      );

  static TextStyle get tag => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textBody,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textBody,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get button => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.isLightTheme ? Colors.white : AppColors.textPrimary,
      );

  static TextStyle get caption => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get error => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.error,
      );
}
