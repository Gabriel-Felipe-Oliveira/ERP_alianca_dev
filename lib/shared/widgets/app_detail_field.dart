import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Campo read-only para telas de detalhes: label em uppercase + valor.
/// Reutilizável em clientes, produtos, pedidos, etc.
class AppDetailField extends StatelessWidget {
  const AppDetailField({
    super.key,
    required this.label,
    required this.value,
    /// Quando false, o valor é texto simples (sem caixa cinza de input).
    this.filled = true,
  });

  final String label;
  final String value;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final display = value.isEmpty ? '—' : value;
    final valueStyle = AppTextStyles.bodyLarge.copyWith(
      color: AppColors.textPrimary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (filled)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.inputPaddingHorizontal,
              vertical: AppSpacing.inputPaddingVertical,
            ),
            decoration: BoxDecoration(
              color: AppColors.input.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Text(display, style: valueStyle),
          )
        else
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              right: AppSpacing.xs,
            ),
            child: Text(display, style: valueStyle),
          ),
      ],
    );
  }
}
