import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Botão de filtro reutilizável para telas de listagem (ex.: "Todos", "Ativos", "Inativos").
/// Exibe ícone + label com estilo de badge, alinhado à esquerda.
class ListagemFilterButton extends StatelessWidget {
  const ListagemFilterButton({
    super.key,
    required this.label,
    this.icon = Icons.folder,
    this.onTap,
    this.isSelected = true,
  });

  /// Texto exibido no botão.
  final String label;

  /// Ícone à esquerda do label.
  final IconData icon;

  /// Callback ao tocar no botão.
  final VoidCallback? onTap;

  /// Se o botão está selecionado (altera cores).
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppColors.contentBackground
        : AppColors.listagemItemBackground;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(
            AppSpacing.listagemCodeBadgeBorderRadius,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
