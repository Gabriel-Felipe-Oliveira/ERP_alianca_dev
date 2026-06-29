import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_modais.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_painel_base.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_section_header.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_tabela_itens.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Painel com a lista de itens do pedido e o botão de adicionar produtos.
class PedidoCriarPainelItens extends StatelessWidget {
  const PedidoCriarPainelItens({
    super.key,
    required this.vm,
    this.expandirCorpo = false,
  });

  final PedidoCriarViewModel vm;
  final bool expandirCorpo;

  @override
  Widget build(BuildContext context) {
    return PedidoCriarPainelBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: expandirCorpo ? MainAxisSize.max : MainAxisSize.min,
        children: [
          PedidoCriarSectionHeader(
            title: 'Itens do Pedido',
            icon: Icons.receipt_long_outlined,
            trailing: IgnorePointer(
              ignoring: vm.clienteSelecionado == null,
              child: Opacity(
                opacity: vm.clienteSelecionado != null ? 1 : 0.45,
                child: ElevatedButton.icon(
                  onPressed: vm.clienteSelecionado != null
                      ? () =>
                          PedidoCriarModais.abrirSelecaoProdutos(context, vm)
                      : null,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar Produtos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.35),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.18),
                    disabledForegroundColor:
                        Colors.white.withValues(alpha: 0.55),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (expandirCorpo)
            Expanded(
              child: PedidoCriarTabelaItens(
                vm: vm,
                expandirCorpo: true,
              ),
            )
          else
            PedidoCriarTabelaItens(vm: vm),
        ],
      ),
    );
  }
}
