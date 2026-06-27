import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/clientes/view/widgets/client_tile.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Linha de cliente na mini listagem do modal de pedido.
class PedidoSelecaoClienteLinha extends StatelessWidget {
  const PedidoSelecaoClienteLinha({
    super.key,
    required this.nome,
    required this.telefone,
    required this.codigo,
    required this.onTap,
    this.selecionado = false,
  });

  final String nome;
  final String telefone;
  final String codigo;
  final VoidCallback onTap;
  final bool selecionado;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selecionado
        ? AppColors.primary.withValues(alpha: 0.35)
        : const Color(0xFFF1F5F9);
    final borderColor = selecionado
        ? AppColors.primary.withValues(alpha: 0.7)
        : Colors.transparent;
    final iconColor =
        selecionado ? AppColors.primary : const Color(0xFF475569);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: selecionado
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.04),
        splashColor: AppColors.primary.withValues(alpha: 0.25),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
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
                selecionado ? Icons.check_circle : Icons.person_outline,
                size: 20,
                color: iconColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 72,
                child: Text(
                  codigo,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  nome,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                ClientTile.formatarTelefoneExibicao(telefone),
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
