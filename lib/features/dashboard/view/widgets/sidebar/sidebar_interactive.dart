import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Utilitários visuais compartilhados pelos itens interativos da sidebar.
abstract final class SidebarInteractive {
  static const double _lightItemRadius = 10;

  static Color background({
    required bool isHovered,
    required bool isSelected,
  }) {
    if (AppColors.isLightTheme) {
      if (isSelected) return AppColors.sidebarMenuActiveBackground;
      if (isHovered) return AppColors.sidebarMenuHoverBackground;
      return Colors.transparent;
    }
    if (isSelected) {
      return AppColors.listagemItemHover.withValues(alpha: 0.42);
    }
    if (isHovered) {
      return AppColors.listagemItemHover.withValues(alpha: 0.28);
    }
    return Colors.transparent;
  }

  static BorderSide selectedBorderSide(bool isSelected) {
    if (AppColors.isLightTheme) {
      return BorderSide.none;
    }
    return BorderSide(
      color: isSelected ? AppColors.primary : Colors.transparent,
      width: isSelected ? SidebarLayout.selectedIndicatorWidth : 0,
    );
  }

  static BorderRadius? itemBorderRadius({
    required bool isHovered,
    required bool isSelected,
  }) {
    if (AppColors.isLightTheme && (isSelected || isHovered)) {
      return BorderRadius.circular(_lightItemRadius);
    }
    return null;
  }
}

/// Divisor sutil entre seções da sidebar.
class SidebarSubtleDivider extends StatelessWidget {
  const SidebarSubtleDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SidebarLayout.sectionGap),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.isLightTheme
            ? AppColors.border
            : AppColors.sidebarDivider.withValues(alpha: 0.55),
      ),
    );
  }
}

/// Layout e tokens visuais da sidebar (ERP).
abstract final class SidebarLayout {
  static const double selectedIndicatorWidth = 4;
  static const double iconSize = 22;
  static const double menuItemMarginBottom = 14;
  static const double sectionGap = 12;
  static const Duration hoverDuration = Duration(milliseconds: 180);
  static const double itemMinHeight = 42;
  static const double toggleButtonSize = 32;
}
