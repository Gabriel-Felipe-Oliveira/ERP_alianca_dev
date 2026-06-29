import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_interactive.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_simple_menu_item.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Botão "Sair" da sidebar — versão expandida e compacta.
class SidebarLogoutButton extends StatefulWidget {
  const SidebarLogoutButton({
    super.key,
    required this.onPressed,
    this.compact = false,
  });

  final VoidCallback onPressed;
  final bool compact;

  @override
  State<SidebarLogoutButton> createState() => _SidebarLogoutButtonState();
}

class _SidebarLogoutButtonState extends State<SidebarLogoutButton> {
  bool _isHovered = false;

  Color get _contentColor =>
      _isHovered ? AppColors.error : AppColors.sidebarTextMuted;

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return SidebarCollapsedIconTile(
        icon: Icons.logout_outlined,
        label: 'Sair',
        isSelected: false,
        iconColor: _contentColor,
        onTap: widget.onPressed,
        onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
      );
    }

    return SidebarInteractiveTile(
      isSelected: false,
      isHovered: _isHovered,
      onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
      onTap: widget.onPressed,
      marginBottom: 0,
      child: Row(
        children: [
          Icon(
            Icons.logout_outlined,
            color: _contentColor,
            size: SidebarLayout.iconSize,
          ),
          const SizedBox(width: 12),
          Text(
            'Sair',
            style: TextStyle(
              color: _contentColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              letterSpacing: -0.02,
            ),
          ),
        ],
      ),
    );
  }
}
