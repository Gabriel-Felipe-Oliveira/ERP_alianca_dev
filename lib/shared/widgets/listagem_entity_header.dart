import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Header da entidade na listagem: gradiente, código em badge e nome em destaque.
/// Protagonista visual da tela.
class ListagemEntityHeader extends StatelessWidget {
  const ListagemEntityHeader({
    super.key,
    required this.codigo,
    required this.nome,
    this.trailing,
  });

  final String codigo;
  final String nome;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.listagemScreenPadding),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.listagemHeaderGradientStart,
              AppColors.listagemHeaderGradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.listagemHeaderBorderRadius),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.listagemCodeBadgeBorderRadius),
              ),
              child: Text(
                codigo,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                nome,
                style: AppTextStyles.heading3.copyWith(fontSize: 20),
              ),
            ),
            ...? (trailing != null ? [trailing!] : null),
          ],
        ),
      ),
    );
  }
}
