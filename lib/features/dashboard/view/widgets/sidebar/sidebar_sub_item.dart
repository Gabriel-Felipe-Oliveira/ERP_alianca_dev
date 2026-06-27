import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_interactive.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_item_colors.dart';

/// Sub-item dentro de um menu expansível.
class SidebarSubItem extends StatefulWidget {
  final String title;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarSubItem({
    super.key,
    required this.title,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SidebarSubItem> createState() => _SidebarSubItemState();
}

class _SidebarSubItemState extends State<SidebarSubItem> {
  bool _isHovered = false;

  Color get _textColor => SidebarItemColors.textColor(
        isSelected: widget.isSelected,
        isHovered: _isHovered,
      );

  BoxDecoration _decoration() {
    if (AppColors.isLightTheme) {
      return BoxDecoration(
        color: widget.isSelected
            ? AppColors.sidebarMenuActiveBackground
            : _isHovered
                ? AppColors.sidebarMenuHoverBackground
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      );
    }

    return BoxDecoration(
      color: widget.isSelected
          ? AppColors.listagemItemHover.withValues(alpha: 0.35)
          : _isHovered
              ? AppColors.listagemItemHover.withValues(alpha: 0.2)
              : null,
      border: Border(
        left: BorderSide(
          color: widget.isSelected ? AppColors.primary : Colors.transparent,
          width: widget.isSelected
              ? SidebarLayout.selectedIndicatorWidth
              : 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          hoverColor: Colors.transparent,
          borderRadius: AppColors.isLightTheme
              ? BorderRadius.circular(8)
              : BorderRadius.zero,
          child: AnimatedContainer(
            duration: SidebarLayout.hoverDuration,
            curve: Curves.easeOut,
            height: SidebarConstants.connectorRowHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: SidebarConstants.subItemPaddingHorizontal,
            ),
            decoration: _decoration(),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: TextStyle(
                color: _textColor,
                fontWeight: SidebarItemColors.textWeight(widget.isSelected),
                fontSize: 12,
                letterSpacing: -0.02,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
