import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Texto inline (somente leitura, sem caixa de input).
class PedidoItemInlineText extends StatelessWidget {
  const PedidoItemInlineText({super.key, required this.value, this.fontSize = 14});

  final String value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      value.isEmpty ? '—' : value,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontSize: fontSize,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
