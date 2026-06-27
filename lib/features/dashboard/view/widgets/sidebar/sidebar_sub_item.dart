import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';

/// Sub-item dentro de um menu expansível.
/// Exibe uma opção secundária (ex: Criar, Editar, Excluir) conectada ao item pai.
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

  Color get _textColor {
    if (widget.isSelected) return AppColors.sidebarTextActive;
    if (_isHovered) return AppColors.sidebarTextHover;
    return AppColors.sidebarTextMuted;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.zero,
        child: Container(
          height: SidebarConstants.connectorRowHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: SidebarConstants.subItemPaddingHorizontal,
          ),
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
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            style: TextStyle(
              color: _textColor,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
              letterSpacing: -0.02,
            ),
          ),
        ),
      ),
    );
  }
}
