import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/routes/app_router.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/shared/viewmodels/navigation_controller.dart';
import 'package:erp_alianca_dev/features/clientes/view/widgets/client_filter_row.dart';
import 'package:erp_alianca_dev/features/clientes/view/widgets/client_list.dart';
import 'package:erp_alianca_dev/features/clientes/view/widgets/client_search_bar.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/clientes_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/pagination_scroll.dart';
import 'package:erp_alianca_dev/shared/widgets/app_shimmer.dart';
import 'package:erp_alianca_dev/shared/widgets/list_load_more_footer.dart';

/// Tela de listagem de clientes.
/// Layout: barra de busca → linha de filtros (pills) → lista em 100% da largura.
class ClientesView extends StatefulWidget {
  const ClientesView({super.key});

  @override
  State<ClientesView> createState() => _ClientesViewState();
}

class _ClientesViewState extends State<ClientesView> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<ClientesViewModel>();
      if (vm.query.isNotEmpty) {
        vm.resetBusca(notify: false);
        if (_searchController.text.isNotEmpty) {
          _searchController.clear();
        }
      }
      vm.loadClientes();
      attachPaginationScrollListener(
        controller: _listScrollController,
        hasMore: () {
          final current = context.read<ClientesViewModel>();
          return current.query.trim().isNotEmpty
              ? current.hasMoreBusca
              : current.hasMoreClientes;
        },
        isLoadingMore: () {
          final current = context.read<ClientesViewModel>();
          return current.query.trim().isNotEmpty
              ? current.isLoadingMoreBusca
              : current.isLoadingMoreClientes;
        },
        onLoadMore: () {
          final current = context.read<ClientesViewModel>();
          if (current.query.trim().isNotEmpty) {
            current.loadMoreBusca();
          } else {
            current.loadMoreClientes();
          }
        },
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

  void _agendarLimpezaBusca() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ClientesViewModel>().resetBusca(notify: false);
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    });
  }

  @override
  void deactivate() {
    _agendarLimpezaBusca();
    super.deactivate();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ClientesViewModel>().resetBusca(notify: false);
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
      }
      context.read<ClientesViewModel>().loadClientes();
    });
  }

  /// Lista a exibir: sem busca usa clientesTodos; com busca usa clientesBusca (ou anterior durante loading).
  List<ClienteModel> _listaParaExibir(ClientesViewModel vm, bool isBuscando) {
    if (!isBuscando) return vm.clientesTodos;
    if (vm.stateBusca == ViewState.success) return vm.clientesBusca;
    return vm.clientesBusca.isNotEmpty ? vm.clientesBusca : vm.clientesTodos;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientesViewModel>(
      builder: (context, vm, _) {
        final isBuscando = vm.query.trim().isNotEmpty;
        final clientes = _listaParaExibir(vm, isBuscando);
        final loadingLista = vm.state == ViewState.loading && vm.clientesTodos.isEmpty;
        final errorLista = vm.state == ViewState.error && vm.clientesTodos.isEmpty;

        final countAtual = isBuscando ? vm.clientesBusca.length : vm.clientesTodos.length;
        final totalAtual = isBuscando ? vm.totalBusca : vm.totalClientes;
        final countLabel = totalAtual > countAtual
            ? '$countAtual de $totalAtual clientes'
            : (clientes.length == 1
                ? '1 cliente encontrado'
                : '${clientes.length} clientes encontrados');

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
              ClientSearchBar(controller: _searchController),
              const SizedBox(height: AppSpacing.section),
              ClientFilterRow(
                items: [
                  ClientFilterChipItem(
                    label: 'Ativo',
                    isSelected: vm.selectedFilter == ClientesViewModel.filterAtivo,
                    onTap: () => vm.setFilter(ClientesViewModel.filterAtivo),
                    count: vm.selectedFilter == ClientesViewModel.filterAtivo
                        ? countAtual
                        : null,
                  ),
                  ClientFilterChipItem(
                    label: 'Inativo',
                    isSelected: vm.selectedFilter == ClientesViewModel.filterInativo,
                    onTap: () => vm.setFilter(ClientesViewModel.filterInativo),
                    count: vm.selectedFilter == ClientesViewModel.filterInativo
                        ? countAtual
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              Align(
                alignment: Alignment.centerLeft,
                child: IgnorePointer(
                  child: Text(
                    countLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              Expanded(
                child: _buildMainContent(
                  vm,
                  clientes: clientes,
                  isBuscando: isBuscando,
                  loadingLista: loadingLista,
                  errorLista: errorLista,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(
    ClientesViewModel vm, {
    required List<ClienteModel> clientes,
    required bool isBuscando,
    required bool loadingLista,
    required bool errorLista,
  }) {
    if (loadingLista) {
      return _buildShimmerList();
    }
    if (errorLista) {
      return _buildErrorState(vm);
    }
    if (clientes.isEmpty) {
      return _buildEmptyState(context, vm, isBuscando);
    }
    return Scrollbar(
      controller: _listScrollController,
      thumbVisibility: true,
      child: ClientList(
        clientes: clientes,
        scrollController: _listScrollController,
        footer: ListLoadMoreFooter(
          isLoadingMore: isBuscando
              ? vm.isLoadingMoreBusca
              : vm.isLoadingMoreClientes,
          hasMore: isBuscando ? vm.hasMoreBusca : vm.hasMoreClientes,
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
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

  Widget _buildErrorState(ClientesViewModel vm) {
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
              onPressed: () => vm.loadClientes(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ClientesViewModel vm,
    bool isBuscando,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isBuscando
                  ? 'Nenhum cliente encontrado para esta busca.'
                  : 'Nenhum cliente cadastrado.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            if (isBuscando)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  vm.resetBusca();
                },
                child: const Text('Limpar busca'),
              )
            else
              FilledButton(
                onPressed: () {
                  context.read<NavigationController>().registrarRota(
                        AppRoutes.clientesCriar,
                      );
                  context.go(AppRoutes.clientesCriar);
                },
                child: const Text('Cadastrar cliente'),
              ),
          ],
        ),
      ),
    );
  }
}
