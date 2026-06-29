import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tooltip.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_interactive.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_item_colors.dart';

/// Item simples da sidebar (sem subseções).
class SidebarMenuItem extends StatefulWidget {
  const SidebarMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    required this.isSelected,
    required this.onTap,
    this.isCollapsed = false,
  });

  final IconData icon;
  final String title;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCollapsed;

  @override
  State<SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<SidebarMenuItem> {
  bool _isHovered = false;

  Color get _textColor => SidebarItemColors.textColor(
        isSelected: widget.isSelected,
        isHovered: _isHovered,
      );

  Color get _iconColor => SidebarItemColors.iconColor(
        isSelected: widget.isSelected,
        isHovered: _isHovered,
      );

  @override
  Widget build(BuildContext context) {
    if (widget.isCollapsed) {
      return SidebarCollapsedIconTile(
        icon: widget.icon,
        label: widget.title,
        isSelected: widget.isSelected,
        iconColor: _iconColor,
        onTap: widget.onTap,
        onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
      );
    }

    return SidebarInteractiveTile(
      isSelected: widget.isSelected,
      isHovered: _isHovered,
      onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
      onTap: widget.onTap,
      child: Row(
        children: [
          Icon(
            widget.icon,
            color: _iconColor,
            size: SidebarLayout.iconSize,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _textColor,
                fontWeight: SidebarItemColors.textWeight(widget.isSelected),
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

/// Tile com hover animado e indicador de seleção.
class SidebarInteractiveTile extends StatelessWidget {
  const SidebarInteractiveTile({
    super.key,
    required this.isSelected,
    required this.isHovered,
    required this.onHoverChanged,
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.marginBottom = SidebarConstants.menuItemMarginBottom,
  });

  final bool isSelected;
  final bool isHovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      child: MouseRegion(
        onEnter: (_) => onHoverChanged(true),
        onExit: (_) => onHoverChanged(false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: SidebarLayout.hoverDuration,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: SidebarInteractive.background(
              isHovered: isHovered,
              isSelected: isSelected,
            ),
            borderRadius: SidebarInteractive.itemBorderRadius(
              isHovered: isHovered,
              isSelected: isSelected,
            ),
            border: Border(
              left: SidebarInteractive.selectedBorderSide(isSelected),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              hoverColor: Colors.transparent,
              splashColor: AppColors.primary.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SidebarConstants.itemContentPaddingHorizontal,
                  vertical: 10,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tile compacto (somente ícone) usado quando a sidebar está recolhida.
class SidebarCollapsedIconTile extends StatefulWidget {
  const SidebarCollapsedIconTile({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.iconColor,
    required this.onTap,
    required this.onHoverChanged,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color iconColor;
  final VoidCallback onTap;
  final ValueChanged<bool> onHoverChanged;

  @override
  State<SidebarCollapsedIconTile> createState() =>
      _SidebarCollapsedIconTileState();
}

class _SidebarCollapsedIconTileState extends State<SidebarCollapsedIconTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SidebarConstants.menuItemMarginBottom),
      child: AppTooltip(
        message: widget.label,
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            widget.onHoverChanged(true);
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            widget.onHoverChanged(false);
          },
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: SidebarLayout.hoverDuration,
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: SidebarInteractive.background(
                isHovered: _isHovered,
                isSelected: widget.isSelected,
              ),
              borderRadius: SidebarInteractive.itemBorderRadius(
                isHovered: _isHovered,
                isSelected: widget.isSelected,
              ),
              border: Border(
                left: SidebarInteractive.selectedBorderSide(widget.isSelected),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                hoverColor: Colors.transparent,
                child: SizedBox(
                  height: SidebarLayout.itemMinHeight,
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: SidebarLayout.iconSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
