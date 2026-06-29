import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_interactive.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tooltip.dart';

/// Botão circular que recolhe/expande a sidebar.
class SidebarToggleButton extends StatefulWidget {
  const SidebarToggleButton({
    super.key,
    required this.isCollapsed,
    required this.onPressed,
  });

  final bool isCollapsed;
  final VoidCallback onPressed;

  @override
  State<SidebarToggleButton> createState() => _SidebarToggleButtonState();
}

class _SidebarToggleButtonState extends State<SidebarToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AppTooltip(
      message: widget.isCollapsed ? 'Expandir menu' : 'Recolher menu',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: SidebarLayout.hoverDuration,
          curve: Curves.easeOut,
          width: SidebarLayout.toggleButtonSize,
          height: SidebarLayout.toggleButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered
                ? AppColors.listagemItemHover.withValues(alpha: 0.35)
                : AppColors.sidebarDivider.withValues(alpha: 0.45),
            border: Border.all(
              color: AppColors.sidebarBorder.withValues(
                alpha: _isHovered ? 0.55 : 0.35,
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onPressed,
              splashColor: AppColors.primary.withValues(alpha: 0.12),
              child: AnimatedSwitcher(
                duration: SidebarLayout.hoverDuration,
                transitionBuilder: (child, animation) => RotationTransition(
                  turns: Tween<double>(begin: 0.85, end: 1).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Icon(
                  widget.isCollapsed
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  key: ValueKey(widget.isCollapsed),
                  size: 20,
                  color: _isHovered
                      ? AppColors.sidebarTextActive
                      : AppColors.sidebarTextMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
