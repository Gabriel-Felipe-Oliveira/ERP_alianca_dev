import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/listagem_letter_group.dart';
import 'package:erp_alianca_dev/shared/widgets/listagem_letter_section_header.dart';
import 'package:erp_alianca_dev/shared/widgets/listagem_list_card.dart';
import 'package:intl/intl.dart';

/// Largura do ícone e da coluna ID na listagem de pedidos.
const double kPedidoListIconWidth = 40;
const double kPedidoListIdColumnWidth = 70;

String formatarMoedaPedidoList(double value) {
  return NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$ ',
    decimalDigits: 2,
  ).format(value);
}

/// Lista de pedidos agrupada por letra do nome do cliente.
class PedidoList extends StatelessWidget {
  const PedidoList({
    super.key,
    required this.pedidos,
    required this.nomeCliente,
    required this.onTap,
    this.scrollController,
    this.footer,
  });

  final List<PedidoListagemModel> pedidos;
  final String Function(int idCliente) nomeCliente;
  final void Function(PedidoListagemModel pedido) onTap;
  final ScrollController? scrollController;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    if (pedidos.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = ListagemLetterGroup.build<PedidoListagemModel>(
      items: pedidos,
      label: (p) => nomeCliente(p.idCliente),
    );

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      itemCount: items.length + (footer != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (footer != null && index == items.length) return footer!;
        final entry = items[index];
        if (entry.isHeader) {
          return ListagemLetterSectionHeader(letter: entry.letter!);
        }
        final pedido = entry.item!;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: PedidoListItem(
            pedido: pedido,
            nomeCliente: nomeCliente(pedido.idCliente),
            onTap: () => onTap(pedido),
          ),
        );
      },
    );
  }
}

class PedidoListItem extends StatelessWidget {
  const PedidoListItem({
    super.key,
    required this.pedido,
    required this.nomeCliente,
    this.onTap,
  });

  final PedidoListagemModel pedido;
  final String nomeCliente;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final idTexto = '#${pedido.idPedido.toString().padLeft(5, '0')}';
    return ListagemListItem(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: kPedidoListIconWidth,
            child: Icon(
              Icons.receipt_long_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(
            width: kPedidoListIdColumnWidth,
            child: Text(
              idTexto,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              nomeCliente,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            formatarMoedaPedidoList(pedido.total),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
