import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Fundo branco para o item (destacar no painel escuro).
const Color pedidoSelecaoFundoItemBase = Color(0xFFF1F5F9);

/// Linha de produto: fundo branco por padrão (destaca); quando escolhido fica azul.
class PedidoSelecaoProdutoLinha extends StatelessWidget {
  const PedidoSelecaoProdutoLinha({
    super.key,
    required this.nome,
    required this.precoTexto,
    required this.onTap,
    this.jaAdicionado = false,
  });

  final String nome;
  final String precoTexto;
  final VoidCallback onTap;
  final bool jaAdicionado;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = jaAdicionado
        ? AppColors.primary.withValues(alpha: 0.35)
        : pedidoSelecaoFundoItemBase;
    final borderColor = jaAdicionado
        ? AppColors.primary.withValues(alpha: 0.7)
        : Colors.transparent;
    final iconColor = jaAdicionado
        ? AppColors.primary
        : const Color(0xFF475569);
    final nomeColor = jaAdicionado
        ? AppColors.textPrimary
        : const Color(0xFF0F172A);
    final precoColor = jaAdicionado
        ? AppColors.textSecondary
        : const Color(0xFF64748B);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: jaAdicionado
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.04),
        splashColor: AppColors.primary.withValues(alpha: 0.25),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: borderColor != Colors.transparent
                ? Border.all(color: borderColor, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                jaAdicionado ? Icons.check_circle : Icons.inventory_2_outlined,
                size: 20,
                color: iconColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nome,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: nomeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      precoTexto,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: precoColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                jaAdicionado ? Icons.add_circle : Icons.add_circle_outline,
                color: iconColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
