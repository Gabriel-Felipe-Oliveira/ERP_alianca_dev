import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_list.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedidos_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_router.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/pagination_scroll.dart';
import 'package:erp_alianca_dev/shared/widgets/app_shimmer.dart';
import 'package:erp_alianca_dev/shared/widgets/list_load_more_footer.dart';
import 'package:intl/intl.dart';
import 'package:erp_alianca_dev/shared/widgets/listagem_list_card.dart';

String _formatarMoeda(double value) {
  return NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$ ',
    decimalDigits: 2,
  ).format(value);
}

/// Colunas do cabeçalho/rodapé da listagem de pedidos.
const List<ListagemListColumnSpec> _kPedidoListColumns = [
  ListagemListColumnSpec(
    label: 'ID',
    width: kPedidoListIconWidth + kPedidoListIdColumnWidth,
  ),
  ListagemListColumnSpec(label: 'Nome', flex: 1),
  ListagemListColumnSpec(label: 'Valor', flex: 0),
];

/// Tela de listagem de pedidos. Padrão igual a cliente/listagem.
class PedidosView extends StatefulWidget {
  const PedidosView({super.key});

  @override
  State<PedidosView> createState() => _PedidosViewState();
}

class _PedidosViewState extends State<PedidosView> with RouteAware {
  final ScrollController _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _recarregarPedidos();
      attachPaginationScrollListener(
        controller: _listScrollController,
        hasMore: () => context.read<PedidosViewModel>().hasMorePedidos,
        isLoadingMore: () =>
            context.read<PedidosViewModel>().isLoadingMorePedidos,
        onLoadMore: () => context.read<PedidosViewModel>().loadMorePedidos(),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.unsubscribe(this);
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _recarregarPedidos();
    });
  }

  void _recarregarPedidos() {
    context.read<PedidosViewModel>().loadPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidosViewModel>(
      builder: (context, vm, _) {
        final lista = vm.pedidos;
        final loadingLista = vm.state == ViewState.loading && vm.pedidos.isEmpty;
        final errorLista = vm.state == ViewState.error && vm.pedidos.isEmpty;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingLateral,
            AppSpacing.sm,
            AppSpacing.screenPaddingLateral,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...kPedidoStatusFiltros.map((f) {
                    final isSelected = vm.statusFiltro == f.value;
                    return FilterChip(
                      label: Text(f.label),
                      selected: isSelected,
                      onSelected: (_) {
                        vm.setStatusFiltro(f.value);
                        vm.loadPedidos();
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  lista.length == 1
                      ? '1 pedido encontrado'
                      : '${lista.length} pedidos encontrados',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              Expanded(
                child: _buildMainContent(context, vm, lista, loadingLista, errorLista),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    PedidosViewModel vm,
    List<PedidoListagemModel> lista,
    bool loadingLista,
    bool errorLista,
  ) {
    if (loadingLista) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: 8,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppShimmer(
            width: double.infinity,
            height: 64,
          ),
        ),
      );
    }
    if (errorLista) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vm.errorMessage,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => vm.loadPedidos(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (lista.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nenhum pedido encontrado.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () {
                  context.go(AppRoutes.pedidosCriar);
                },
                child: const Text('Novo pedido'),
              ),
            ],
          ),
        ),
      );
    }
    final totalGeral = vm.totalGeralListagem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListagemListHeader(columns: _kPedidoListColumns),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: Scrollbar(
            controller: _listScrollController,
            thumbVisibility: true,
            child: PedidoList(
              pedidos: lista,
              scrollController: _listScrollController,
              nomeCliente: vm.nomeCliente,
              onTap: (p) => context.push(AppRoutes.pedidosDetalhesId(p.idPedido)),
              footer: ListLoadMoreFooter(
                isLoadingMore: vm.isLoadingMorePedidos,
                hasMore: vm.hasMorePedidos,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ListagemListFooter(
          columns: _kPedidoListColumns,
          lastColumnText: 'Total: ${_formatarMoeda(totalGeral)}',
        ),
      ],
    );
  }
}
