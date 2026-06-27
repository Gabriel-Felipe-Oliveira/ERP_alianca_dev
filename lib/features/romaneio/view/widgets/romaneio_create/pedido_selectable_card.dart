import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';

/// Card clicável de um pedido. Selecionado: borda sutil, mesmo fundo da sidebar.
class PedidoSelectableCard extends StatelessWidget {
  const PedidoSelectableCard({
    super.key,
    required this.pedido,
    required this.isSelected,
    required this.onTap,
    this.nomeCliente,
    this.compact = false,
  });

  final PedidoListagemModel pedido;
  final bool isSelected;
  final VoidCallback onTap;
  final String? nomeCliente;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.cardPaddingCompact),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.sidebarItemBackground
              : AppColors.sidebarBackground,
          borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
          border: Border.all(
            color: AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
            hoverColor: AppColors.sidebarItemBackground.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xs,
                horizontal: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked_outlined,
                    size: compact ? 18 : 22,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Pedido #${pedido.idPedido}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: compact ? 13 : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            (nomeCliente != null &&
                                    nomeCliente!.isNotEmpty &&
                                    nomeCliente != '—')
                                ? nomeCliente!
                                : '#${pedido.idCliente}',
                            style: (compact ? AppTextStyles.bodyMedium : AppTextStyles.bodyLarge)
                                .copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: compact ? 13 : 16,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'R\$ ${formatarPreco(pedido.total)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: compact ? 13 : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
