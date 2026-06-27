import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Cores de ícone/texto dos itens da sidebar conforme estado.
abstract final class SidebarItemColors {
  static Color iconColor({required bool isSelected, required bool isHovered}) {
    if (isSelected && AppColors.isLightTheme) {
      return AppColors.sidebarMenuActiveIcon;
    }
    if (isSelected) return AppColors.sidebarTextActive;
    if (isHovered) return AppColors.sidebarTextHover;
    return AppColors.sidebarTextMuted;
  }

  static Color textColor({required bool isSelected, required bool isHovered}) {
    if (isSelected && AppColors.isLightTheme) {
      return AppColors.sidebarMenuActiveText;
    }
    if (isSelected) return AppColors.sidebarTextActive;
    if (isHovered) return AppColors.sidebarTextHover;
    return AppColors.sidebarTextMuted;
  }

  static FontWeight textWeight(bool isSelected) =>
      isSelected ? FontWeight.w600 : FontWeight.w500;
}
