import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/pedidos/contracts/pedido_selecao_produtos_contract.dart';
import 'package:erp_alianca_dev/features/pedidos/view/pedido_selecao_produtos_modal.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_detalhes_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';

Future<void> pedidoConfirmarCancelar(
  BuildContext context,
  PedidoDetalhesViewModel vm,
) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cancelar pedido'),
      content: const Text(
        'Deseja cancelar este pedido? O status será alterado para "cancelado".',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Não'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Sim, cancelar'),
        ),
      ],
    ),
  );
  if (confirm != true || !context.mounted) return;
  final result = await vm.cancelarPedido();
  if (!context.mounted) return;
  if (result == true) {
    showAppToast(context, message: 'Pedido cancelado.');
  } else if (result == false) {
    showAppToast(
      context,
      message: 'Este pedido já está cancelado ou concluído.',
    );
  } else {
    showAppToast(context, message: vm.errorMessage, isError: true);
  }
}

Future<void> pedidoConfirmarExcluir(
  BuildContext context,
  PedidoDetalhesViewModel vm,
) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Excluir pedido'),
      content: const Text(
        'Deseja realmente excluir (arquivar) este pedido? '
        'Esta ação não pode ser desfeita.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  if (confirm != true || !context.mounted) return;

  final rowsAffected = await vm.arquivarPedido();
  if (!context.mounted) return;
  if (rowsAffected != null) {
    if (rowsAffected > 0) {
      showAppToast(context, message: 'Pedido excluído com sucesso.');
    } else {
      showAppToast(
        context,
        message:
            'Nenhum registro alterado. O pedido pode já estar excluído no servidor.',
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go(AppRoutes.pedidos);
    });
  } else {
    showAppToast(context, message: vm.errorMessage, isError: true);
  }
}

void pedidoAbrirModalSelecaoProdutos(
  BuildContext context,
  PedidoDetalhesViewModel vm,
) {
  vm.produtoQueryController.clear();
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) {
      final size = MediaQuery.sizeOf(ctx);
      final maxHeight = size.height * 0.75;
      final horizontalInset = size.width * 0.05;
      final verticalInset = size.height * 0.125;
      return Dialog(
        backgroundColor: AppColors.contentBackground,
        insetPadding: EdgeInsets.symmetric(
          horizontal: horizontalInset,
          vertical: verticalInset,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size.width - (horizontalInset * 2),
            maxHeight: maxHeight,
          ),
          child: SizedBox(
            height: maxHeight,
            child: ListenableProvider<PedidoSelecaoProdutosVm>.value(
              value: vm,
              child: const PedidoSelecaoProdutosModal(),
            ),
          ),
        ),
      );
    },
  );
}
