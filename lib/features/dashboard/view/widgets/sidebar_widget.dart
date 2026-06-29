import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_footer.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_header.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_interactive.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_navigation.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/viewmodels/theme_palette_provider.dart';

/// Barra lateral do dashboard. Compõe cabeçalho, navegação e rodapé;
/// os subcomponentes vivem em `widgets/sidebar/`.
class SidebarWidget extends StatelessWidget {
  static const double sidebarWidth = SidebarConstants.sidebarExpandedWidth;

  const SidebarWidget({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapsed,
  });

  final bool isCollapsed;
  final VoidCallback onToggleCollapsed;

  @override
  Widget build(BuildContext context) {
    context.watch<ThemePaletteProvider>();
    final targetWidth = isCollapsed
        ? SidebarConstants.sidebarCollapsedWidth
        : SidebarConstants.sidebarExpandedWidth;

    return AnimatedContainer(
      duration: SidebarConstants.sidebarCollapseDuration,
      curve: SidebarConstants.expandAnimationCurve,
      width: targetWidth,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        border: AppColors.isLightTheme
            ? Border(right: BorderSide(color: AppColors.border, width: 1))
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactLayout = constraints.maxWidth <
              SidebarConstants.compactLayoutBreakpoint;
          final horizontalPadding = compactLayout ? 12.0 : 24.0;

          return Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SidebarHeader(
                  compactLayout: compactLayout,
                  isCollapsed: isCollapsed,
                  onToggleCollapsed: onToggleCollapsed,
                ),
                const SidebarSubtleDivider(),
                Expanded(
                  child: SidebarNavigation(compactLayout: compactLayout),
                ),
                SidebarFooter(compactLayout: compactLayout),
              ],
            ),
          );
        },
      ),
    );
  }
}
