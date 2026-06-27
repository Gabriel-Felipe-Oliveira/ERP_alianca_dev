import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_detalhes_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tool_panel.dart';

/// Painel lateral de ações do detalhe do pedido.
class PedidoDetalheToolbarPanel extends StatelessWidget {
  const PedidoDetalheToolbarPanel({
    super.key,
    required this.vm,
    required this.compact,
    required this.onVisualizar,
    required this.onSalvarPdf,
    required this.onCancelarPedido,
    required this.onExcluir,
  });

  final PedidoDetalhesViewModel vm;
  final bool compact;
  final VoidCallback onVisualizar;
  final VoidCallback onSalvarPdf;
  final VoidCallback onCancelarPedido;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final isLoading = vm.state == ViewState.loading && vm.itens.isEmpty;
    final podeCupom = !vm.isEditMode && !isLoading && vm.itens.isNotEmpty;
    final status = vm.statusAtual;
    final pedidoFechado = status == 'concluido' || status == 'cancelado';

    return AppToolPanel(
      compact: compact,
      items: [
        if (!pedidoFechado) ...[
          if (vm.isEditMode)
            AppToolPanelItemConfig(
              icon: Icons.close,
              label: 'Cancelar',
              variant: AppToolPanelItemVariant.neutral,
              onTap: () {
                vm.exitEditMode();
                vm.loadItens();
              },
            )
          else
            AppToolPanelItemConfig(
              icon: Icons.edit_outlined,
              label: 'Editar',
              variant: AppToolPanelItemVariant.success,
              enabled: !isLoading,
              onTap: vm.enterEditMode,
            ),
        ],
        AppToolPanelItemConfig(
          icon: Icons.picture_as_pdf_outlined,
          label: 'Visualizar',
          variant: AppToolPanelItemVariant.neutral,
          enabled: podeCupom,
          onTap: onVisualizar,
        ),
        AppToolPanelItemConfig(
          icon: Icons.save_outlined,
          label: 'Salvar',
          variant: AppToolPanelItemVariant.neutral,
          enabled: podeCupom,
          onTap: onSalvarPdf,
        ),
        if (!pedidoFechado && vm.statusAtual == 'confirmado')
          AppToolPanelItemConfig(
            icon: Icons.cancel_outlined,
            label: 'Cancelar',
            variant: AppToolPanelItemVariant.danger,
            enabled: !vm.isEditMode && !isLoading && !vm.isCancelling,
            onTap: onCancelarPedido,
          ),
        if (vm.statusAtual == 'cancelado')
          AppToolPanelItemConfig(
            icon: Icons.delete_outline,
            label: 'Excluir',
            variant: AppToolPanelItemVariant.danger,
            enabled: !vm.isEditMode && !isLoading && !vm.isDeleting,
            onTap: onExcluir,
          ),
      ],
    );
  }
}
