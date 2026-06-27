import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_detalhes_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';

/// Tabela de itens do pedido (modo visualização).
class PedidoDetalheItensTable extends StatelessWidget {
  const PedidoDetalheItensTable({
    super.key,
    required this.vm,
  });

  final PedidoDetalhesViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(0.6),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1.2),
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: AppColors.inputEnabledBorder.withValues(alpha: 0.6),
        ),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.input.withValues(alpha: 0.5),
          ),
          children: [
            _PedidoTableCell('Produto', isHeader: true),
            _PedidoTableCell('Qtd', isHeader: true),
            _PedidoTableCell('Valor un.', isHeader: true),
            _PedidoTableCell('Subtotal', isHeader: true),
          ],
        ),
        ...vm.itens.map(
          (item) => TableRow(
            children: [
              _PedidoTableCell(
                vm.nomeProduto(item.idProduto),
                isHeader: false,
                maxLines: 2,
              ),
              _PedidoTableCell('${item.quantidade}', isHeader: false),
              _PedidoTableCell(
                'R\$ ${formatarPreco(item.precoUnitario)}',
                isHeader: false,
              ),
              _PedidoTableCell(
                'R\$ ${formatarPreco(item.subtotal)}',
                isHeader: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PedidoTableCell extends StatelessWidget {
  const _PedidoTableCell(
    this.text, {
    required this.isHeader,
    this.maxLines = 1,
  });

  final String text;
  final bool isHeader;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: AppSpacing.sm,
      ),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: isHeader
            ? AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )
            : AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
      ),
    );
  }
}
