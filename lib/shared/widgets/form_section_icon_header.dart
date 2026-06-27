import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Cabeçalho de seção em formulários (título + ícone em badge azul claro).
class FormSectionIconHeader extends StatelessWidget {
  const FormSectionIconHeader({
    super.key,
    required this.title,
    required this.icon,
    this.iconBackgroundColor,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Color? iconBackgroundColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final badgeColor =
        iconBackgroundColor ?? AppColors.primary.withValues(alpha: 0.35);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
