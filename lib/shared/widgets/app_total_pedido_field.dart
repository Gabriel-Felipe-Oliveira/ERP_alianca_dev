import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';

/// Campo visual do total do pedido (final da tela): label + valor em destaque.
/// Reutilizável em Criar Pedido e Detalhes do Pedido.
class AppTotalPedidoField extends StatelessWidget {
  const AppTotalPedidoField({super.key, required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'VALOR TOTAL',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.inputPaddingHorizontal,
            vertical: AppSpacing.inputPaddingVertical,
          ),
          decoration: BoxDecoration(
            color: AppColors.input.withValues(alpha: 0.5),
            borderRadius:
                BorderRadius.circular(AppSpacing.inputBorderRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Text(
            'R\$ ${formatarPreco(total)}',
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
