import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_interactive.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_simple_menu_item.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tooltip.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/viewmodels/theme_palette_provider.dart';

/// Alterna entre modo escuro (padrão) e modo claro. Persiste a preferência localmente.
class AppThemeModeToggle extends StatefulWidget {
  const AppThemeModeToggle({
    super.key,
    this.compact = false,
    this.iconOnly = false,
  });

  final bool compact;
  final bool iconOnly;

  @override
  State<AppThemeModeToggle> createState() => _AppThemeModeToggleState();
}

class _AppThemeModeToggleState extends State<AppThemeModeToggle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themePalette = context.watch<ThemePaletteProvider>();
    final isLight = themePalette.isLightMode;
    final icon = isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined;
    final label = isLight ? 'Modo escuro' : 'Modo claro';

    if (widget.iconOnly) {
      return AppTooltip(
        message: label,
        child: IconButton(
          onPressed: themePalette.toggleThemeMode,
          icon: Icon(icon, size: 20),
          color: AppColors.textSecondary,
          tooltip: windowsSafeTooltip(label),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      );
    }

    if (widget.compact) {
      return SidebarCollapsedIconTile(
        icon: icon,
        label: label,
        isSelected: false,
        iconColor: _isHovered
            ? AppColors.sidebarTextActive
            : AppColors.sidebarTextMuted,
        onTap: themePalette.toggleThemeMode,
        onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
      );
    }

    return SidebarInteractiveTile(
      isSelected: false,
      isHovered: _isHovered,
      onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
      onTap: themePalette.toggleThemeMode,
      marginBottom: AppSpacing.sm,
      child: Row(
        children: [
          Icon(
            icon,
            color: _isHovered
                ? AppColors.sidebarTextActive
                : AppColors.sidebarTextMuted,
            size: SidebarLayout.iconSize,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _isHovered
                    ? AppColors.sidebarTextActive
                    : AppColors.sidebarTextMuted,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                letterSpacing: -0.02,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
