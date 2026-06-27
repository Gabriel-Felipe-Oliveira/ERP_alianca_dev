import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_detalhe_actions.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_detalhe_edit_body.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_detalhe_toolbar_panel.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_detalhe_view_body.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_detalhes_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Tela de detalhes do pedido. Recebe [id_pedido] pela rota e dados do pedido
/// (opcional) via extra. Busca os itens do pedido com [id_pedido].
class PedidoDetalhesView extends StatefulWidget {
  const PedidoDetalhesView({super.key});

  @override
  State<PedidoDetalhesView> createState() => _PedidoDetalhesViewState();
}

class _PedidoDetalhesViewState extends State<PedidoDetalhesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PedidoDetalhesViewModel>().loadItens();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _voltarParaLista() => context.go(AppRoutes.pedidos);

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidoDetalhesViewModel>(
      builder: (context, vm, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < AppSpacing.toolPanelBreakpoint;
            final rightPadding = compact
                ? AppSpacing.toolPanelWidthCompact + AppSpacing.lg + AppSpacing.sm
                : AppSpacing.toolPanelWidth + AppSpacing.lg * 2;

            return Stack(
              children: [
                Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: rightPadding,
                      vertical: AppSpacing.lg,
                    ),
                    child: Center(
                      child: vm.isEditMode
                          ? PedidoDetalheEditBody(
                              vm: vm,
                              onBack: _voltarParaLista,
                            )
                          : PedidoDetalheViewBody(
                              vm: vm,
                              onBack: _voltarParaLista,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  right: AppSpacing.lg,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: PedidoDetalheToolbarPanel(
                      vm: vm,
                      compact: compact,
                      onVisualizar: () => vm.exportarVisualizarCupom(context),
                      onSalvarPdf: () => vm.exportarSalvarCupom(context),
                      onCancelarPedido: () =>
                          pedidoConfirmarCancelar(context, vm),
                      onExcluir: () => pedidoConfirmarExcluir(context, vm),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
