import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_tabela_colunas.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Estrutura de colunas idêntica entre cabeçalho e linhas da tabela de itens.
class PedidoCriarTabelaRowLayout extends StatelessWidget {
  const PedidoCriarTabelaRowLayout({
    super.key,
    required this.produto,
    required this.qtd,
    required this.precoUnit,
    required this.total,
    this.acoes,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.sm,
    ),
  });

  final Widget produto;
  final Widget qtd;
  final Widget precoUnit;
  final Widget total;
  final Widget? acoes;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: produto),
          SizedBox(
            width: PedidoCriarTabelaColunas.qtd,
            child: Align(
              alignment: Alignment.centerLeft,
              child: qtd,
            ),
          ),
          const SizedBox(width: PedidoCriarTabelaColunas.espacoQtdPreco),
          SizedBox(
            width: PedidoCriarTabelaColunas.precoUnit,
            child: Align(
              alignment: Alignment.centerLeft,
              child: precoUnit,
            ),
          ),
          const SizedBox(width: PedidoCriarTabelaColunas.espacoPrecoTotal),
          SizedBox(
            width: PedidoCriarTabelaColunas.total,
            child: Align(
              alignment: Alignment.centerRight,
              child: total,
            ),
          ),
          SizedBox(
            width: PedidoCriarTabelaColunas.acoes,
            height: PedidoCriarTabelaColunas.acoes,
            child: Center(child: acoes ?? const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}
