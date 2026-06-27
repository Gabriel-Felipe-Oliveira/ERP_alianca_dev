import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_detalhe_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';

typedef RomaneioActionProgress = void Function(String? label);

Future<void> romaneioConfirmarCancelar(
  BuildContext context,
  RomaneioDetalheViewModel vm,
  RomaneioActionProgress setProgress,
) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cancelar romaneio'),
      content: const Text(
        'Deseja cancelar este romaneio? O status será alterado para "cancelado".',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Não'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: const Text('Sim, cancelar'),
        ),
      ],
    ),
  );
  if (confirm != true || !context.mounted) return;
  setProgress('Cancelar romaneio');
  try {
    final ok = await vm.cancelarRomaneio();
    if (!context.mounted) return;
    if (ok) {
      showAppToast(context, message: 'Romaneio cancelado.');
    } else if (vm.errorMessage.isNotEmpty) {
      showAppToast(context, message: vm.errorMessage, isError: true);
    }
  } finally {
    setProgress(null);
  }
}

Future<void> romaneioConfirmarExcluir(
  BuildContext context,
  RomaneioDetalheViewModel vm,
  RomaneioActionProgress setProgress,
) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Excluir romaneio'),
      content: const Text(
        'Deseja arquivar este romaneio e todos os pedidos dele? '
        'O romaneio e os pedidos não aparecerão na listagem padrão.',
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
  setProgress('Excluir romaneio');
  try {
    final ok = await vm.arquivarRomaneio();
    if (!context.mounted) return;
    if (ok) {
      showAppToast(context, message: 'Romaneio arquivado.');
      context.go(AppRoutes.romaneio);
    } else {
      showAppToast(context, message: vm.errorMessage, isError: true);
    }
  } finally {
    setProgress(null);
  }
}

Future<void> romaneioAbrirModalAdicionarPedido(
  BuildContext context,
  RomaneioDetalheViewModel vm,
) async {
  await vm.carregarPedidosParaAdicionar();
  if (!context.mounted) return;
  final lista = vm.pedidosDisponiveisParaAdicionar;
  if (lista.isEmpty) {
    showAppToast(
      context,
      message: 'Nenhum pedido confirmado disponível para adicionar.',
    );
    return;
  }
  final escolhido = await showModalBottomSheet<PedidoListagemModel>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Selecione um pedido para adicionar',
              style: AppTextStyles.sectionTitle,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: lista.length,
              itemBuilder: (_, i) {
                final p = lista[i];
                return ListTile(
                  title: Text(vm.idPedidoFormatado(p)),
                  subtitle: Text(vm.nomeClienteDoPedido(p.idPedido)),
                  trailing: Text(vm.valorFormatadoPedido(p)),
                  onTap: () => Navigator.of(ctx).pop(p),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
  if (escolhido != null && context.mounted) {
    vm.adicionarPedidoAoRomaneio(escolhido);
  }
}
