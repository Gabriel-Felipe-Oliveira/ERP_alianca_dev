import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

class RomaneioCreatePageHeader extends StatelessWidget {
  const RomaneioCreatePageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Criar Romaneio',
          style: AppTextStyles.pageHeaderTitle.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 4),
        Text(
          'Agrupe pedidos prontos para entrega e informe os dados logísticos.',
          style: AppTextStyles.pageHeaderDescription.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
