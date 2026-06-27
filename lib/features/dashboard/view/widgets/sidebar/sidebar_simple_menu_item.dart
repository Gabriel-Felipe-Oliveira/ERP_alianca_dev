import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';

/// Item simples da sidebar (sem subseções).
/// Responsável apenas por exibir e navegar para uma rota única.
class SidebarMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<SidebarMenuItem> {
  bool _isHovered = false;

  Color get _textColor {
    if (widget.isSelected) return AppColors.sidebarTextActive;
    if (_isHovered) return AppColors.sidebarTextHover;
    return AppColors.sidebarTextMuted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SidebarConstants.menuItemMarginBottom),
      decoration: BoxDecoration(
        color: widget.isSelected ? AppColors.sidebarDivider : null,
        borderRadius: BorderRadius.zero,
        border: Border(
          left: BorderSide(
            color: widget.isSelected ? AppColors.primary : Colors.transparent,
            width: widget.isSelected ? 3 : 0,
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SidebarConstants.itemContentPaddingHorizontal,
            vertical: SidebarConstants.itemContentPaddingVertical,
          ),
          leading: Icon(
            widget.icon,
            color: _textColor,
            size: 20,
          ),
          title: Text(
            widget.title,
            style: TextStyle(
              color: _textColor,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
              letterSpacing: -0.02,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
