import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_toggle_button.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_logo.dart';

/// Cabeçalho da sidebar: logo + título (expandido) ou apenas o toggle (compacto).
class SidebarHeader extends StatelessWidget {
  const SidebarHeader({
    super.key,
    required this.compactLayout,
    required this.isCollapsed,
    required this.onToggleCollapsed,
  });

  final bool compactLayout;
  final bool isCollapsed;
  final VoidCallback onToggleCollapsed;

  @override
  Widget build(BuildContext context) {
    if (compactLayout) {
      return Center(
        child: SidebarToggleButton(
          isCollapsed: isCollapsed,
          onPressed: onToggleCollapsed,
        ),
      );
    }

    return Row(
      children: [
        const AppLogo(
          width: 28,
          height: 28,
          fallbackIcon: Icons.storefront_outlined,
          fallbackIconSize: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Vendas Base',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.sidebarTextActive,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: -0.02,
            ),
          ),
        ),
        SidebarToggleButton(
          isCollapsed: isCollapsed,
          onPressed: onToggleCollapsed,
        ),
      ],
    );
  }
}
