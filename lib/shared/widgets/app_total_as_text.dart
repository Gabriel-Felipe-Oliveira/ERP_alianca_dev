import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Total exibido como texto na tela (sem input), para não misturar com os campos.
/// Reutilizável em Criar Pedido e Detalhes do Pedido.
class AppTotalAsText extends StatelessWidget {
  const AppTotalAsText({
    super.key,
    required this.value,
    this.label = 'TOTAL',
    this.caption = 'Calculado automaticamente.',
  });

  final String value;
  final String label;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value.isEmpty ? '—' : value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            caption!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ],
    );
  }
}
