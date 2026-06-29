import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/pedidos/contracts/pedido_selecao_produtos_contract.dart';
import 'package:erp_alianca_dev/features/pedidos/view/pedido_selecao_cliente_modal.dart';
import 'package:erp_alianca_dev/features/pedidos/view/pedido_selecao_produtos_modal.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Diálogos de seleção (cliente/produtos) usados na criação de pedido.
abstract final class PedidoCriarModais {
  static const double _modalFraction = 0.5;

  static void abrirSelecaoCliente(
    BuildContext context,
    PedidoCriarViewModel vm,
  ) {
    _abrirDialog(
      context,
      ListenableProvider<PedidoCriarViewModel>.value(
        value: vm,
        child: const PedidoSelecaoClienteModal(),
      ),
    );
  }

  static void abrirSelecaoProdutos(
    BuildContext context,
    PedidoCriarViewModel vm,
  ) {
    vm.limparBuscaProduto();
    _abrirDialog(
      context,
      ListenableProvider<PedidoSelecaoProdutosVm>.value(
        value: vm,
        child: const PedidoSelecaoProdutosModal(),
      ),
    );
  }

  static void _abrirDialog(BuildContext context, Widget conteudo) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        final size = MediaQuery.sizeOf(ctx);
        final modalWidth = size.width * _modalFraction;
        final modalHeight = size.height * _modalFraction;
        final horizontalInset = (size.width - modalWidth) / 2;
        final verticalInset = (size.height - modalHeight) / 2;
        return Dialog(
          backgroundColor: AppColors.contentBackground,
          insetPadding: EdgeInsets.fromLTRB(
            horizontalInset,
            verticalInset,
            horizontalInset,
            verticalInset,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: modalWidth,
              maxHeight: modalHeight,
            ),
            child: SizedBox(
              width: modalWidth,
              height: modalHeight,
              child: conteudo,
            ),
          ),
        );
      },
    );
  }
}
