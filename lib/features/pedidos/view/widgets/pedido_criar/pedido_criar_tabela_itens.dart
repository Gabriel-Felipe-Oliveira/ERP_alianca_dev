import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_item_table_row.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_tabela_row_layout.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Tabela de itens do pedido (cabeçalho + corpo unificados).
class PedidoCriarTabelaItens extends StatelessWidget {
  const PedidoCriarTabelaItens({
    super.key,
    required this.vm,
    this.expandirCorpo = false,
  });

  final PedidoCriarViewModel vm;
  final bool expandirCorpo;

  static TextStyle get _cabecalhoStyle => AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary.withValues(alpha: 0.85),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      );

  @override
  Widget build(BuildContext context) {
    final corpo = vm.itens.isEmpty
        ? const _ItensEmptyState()
        : ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: !expandirCorpo,
            physics: expandirCorpo
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: vm.itens.length,
            itemBuilder: (context, index) {
              final item = vm.itens[index];
              return PedidoCriarItemTableRow(
                nome: item.produto.nome,
                quantidade: item.quantidade,
                valorUnitario: item.valorEfetivo,
                totalLinha: item.totalLinha,
                index: index,
                onQuantidadeChanged: vm.atualizarQuantidadeItem,
                onValorChanged: vm.atualizarValorItem,
                onRemover: () => vm.removerItem(index),
              );
            },
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.55),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.sidebarDivider.withValues(alpha: 0.28),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.cardBorder.withValues(alpha: 0.45),
                    width: 1,
                  ),
                ),
              ),
              child: PedidoCriarTabelaRowLayout(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 8,
                ),
                produto: Text('Produto', style: _cabecalhoStyle),
                qtd: Text('Qtd.', style: _cabecalhoStyle),
                precoUnit: Text('Preço Unit.', style: _cabecalhoStyle),
                total: Text(
                  'Total',
                  style: _cabecalhoStyle,
                  textAlign: TextAlign.end,
                ),
              ),
            ),
            if (expandirCorpo)
              Expanded(child: corpo)
            else
              corpo,
          ],
        ),
      ),
    );
  }
}

class _ItensEmptyState extends StatelessWidget {
  const _ItensEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      color: AppColors.listagemItemBackground.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 36,
              color: AppColors.textSecondary.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nenhum produto adicionado',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Adicione produtos para montar o pedido.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
