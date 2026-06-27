import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Marcador de seção por letra na listagem (ex.: "G" + linha divisória).
class ListagemLetterSectionHeader extends StatelessWidget {
  const ListagemLetterSectionHeader({
    super.key,
    required this.letter,
  });

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.section,
        bottom: AppSpacing.section,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            letter,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.textPrimary.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}
