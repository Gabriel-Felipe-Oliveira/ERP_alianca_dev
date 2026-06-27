import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_sub_item.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_sub_items_connector.dart';

/// Item expansível da sidebar (com subseções).
/// Exibe o item principal e, quando expandido, lista os subitens com conectores.
class SidebarMenuItemExpandable extends StatefulWidget {
  final IconData icon;
  final String title;
  final String baseRoute;
  final String currentLocation;
  final VoidCallback onTapBase;

  /// Ao segurar (long-press) com a seção aberta: fecha e vai para Home.
  final VoidCallback? onLongPressBase;

  final List<SidebarSubItem> subItems;

  /// Se definido, força a seção a colapsar (usado para animação sequencial).
  final String? collapsingSection;

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
  });

  @override
  State<SidebarMenuItemExpandable> createState() =>
      _SidebarMenuItemExpandableState();
}

class _SidebarMenuItemExpandableState extends State<SidebarMenuItemExpandable> {
  bool _isHovered = false;

  /// Expandido = rota ativa E não está sendo forçado a colapsar
  bool get _isExpanded =>
      widget.currentLocation.startsWith(widget.baseRoute) &&
      widget.baseRoute != widget.collapsingSection;

  Color get _textColor {
    if (_isExpanded) return AppColors.sidebarTextActive;
    if (_isHovered) return AppColors.sidebarTextHover;
    return AppColors.sidebarTextMuted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SidebarConstants.menuItemMarginBottom),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMainItem(),
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

  Widget _buildMainItem() {
    return Container(
      decoration: BoxDecoration(
        color: _isExpanded ? AppColors.sidebarDivider : null,
        borderRadius: BorderRadius.zero,
        border: Border(
          left: BorderSide(
            color: _isExpanded ? AppColors.primary : Colors.transparent,
            width: _isExpanded ? 3 : 0,
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
              fontWeight: _isExpanded ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
              letterSpacing: -0.02,
            ),
          ),
          trailing: _isExpanded
              ? Icon(
                  Icons.keyboard_arrow_up,
                  color:
                      _isHovered ? AppColors.sidebarTextHover : AppColors.sidebarTextMuted,
                  size: 16,
                )
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          onTap: widget.onTapBase,
          onLongPress: _isExpanded ? widget.onLongPressBase : null,
        ),
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
