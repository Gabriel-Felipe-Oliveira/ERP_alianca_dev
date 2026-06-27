import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_interactive.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_item_colors.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_simple_menu_item.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_sub_item.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_sub_items_connector.dart';

/// Item expansível da sidebar (com subseções).
class SidebarMenuItemExpandable extends StatefulWidget {
  const SidebarMenuItemExpandable({
    super.key,
    required this.icon,
    required this.title,
    required this.baseRoute,
    required this.currentLocation,
    required this.onTapBase,
    required this.subItems,
    this.onLongPressBase,
    this.collapsingSection,
    this.isCollapsed = false,
  });

  final IconData icon;
  final String title;
  final String baseRoute;
  final String currentLocation;
  final VoidCallback onTapBase;
  final VoidCallback? onLongPressBase;
  final List<SidebarSubItem> subItems;
  final String? collapsingSection;
  final bool isCollapsed;

  @override
  State<SidebarMenuItemExpandable> createState() =>
      _SidebarMenuItemExpandableState();
}

class _SidebarMenuItemExpandableState extends State<SidebarMenuItemExpandable> {
  bool _isHovered = false;

  bool get _isExpanded =>
      !widget.isCollapsed &&
      widget.currentLocation.startsWith(widget.baseRoute) &&
      widget.baseRoute != widget.collapsingSection;

  bool get _isActive =>
      widget.currentLocation.startsWith(widget.baseRoute);

  Color get _textColor => SidebarItemColors.textColor(
        isSelected: _isActive,
        isHovered: _isHovered,
      );

  Color get _iconColor => SidebarItemColors.iconColor(
        isSelected: _isActive,
        isHovered: _isHovered,
      );

  void _onTapCollapsed() {
    context.go(widget.baseRoute);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCollapsed) {
      return SidebarCollapsedIconTile(
        icon: widget.icon,
        label: widget.title,
        isSelected: _isActive,
        iconColor: _iconColor,
        onTap: _onTapCollapsed,
        onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: SidebarConstants.menuItemMarginBottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SidebarInteractiveTile(
            isSelected: _isExpanded,
            isHovered: _isHovered,
            onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
            onTap: widget.onTapBase,
            onLongPress: _isExpanded ? widget.onLongPressBase : null,
            marginBottom: 0,
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
                      fontWeight: SidebarItemColors.textWeight(_isExpanded),
                      fontSize: 14,
                      letterSpacing: -0.02,
                    ),
                  ),
                ),
                if (_isExpanded)
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: _isHovered
                        ? AppColors.sidebarTextHover
                        : AppColors.sidebarTextMuted,
                    size: 18,
                  ),
              ],
            ),
          ),
          AnimatedSize(
            duration: SidebarConstants.expandAnimationDuration,
            curve: SidebarConstants.expandAnimationCurve,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: SidebarConstants.expandAnimationDuration,
              switchInCurve: SidebarConstants.expandAnimationCurve,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
              child: _isExpanded
                  ? _buildSubSections(
                      key: ValueKey('${widget.baseRoute}-expanded'),
                    )
                  : SizedBox.shrink(
                      key: ValueKey('${widget.baseRoute}-collapsed'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSections({Key? key}) {
    return Padding(
      key: key,
      padding: SidebarConstants.subSectionsPadding,
      child: SidebarSubItemsConnector(subItems: widget.subItems),
    );
  }
}
