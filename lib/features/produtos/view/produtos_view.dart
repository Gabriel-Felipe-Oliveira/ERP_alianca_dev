import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/routes/app_router.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/features/produtos/view/widgets/produto_list.dart';
import 'package:erp_alianca_dev/features/produtos/view/widgets/produto_search_bar.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produtos_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/viewmodels/navigation_controller.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/pagination_scroll.dart';
import 'package:erp_alianca_dev/shared/widgets/app_shimmer.dart';
import 'package:erp_alianca_dev/shared/widgets/list_load_more_footer.dart';

/// Tela de listagem de produtos. Padrão igual a cliente/listagem.
class ProdutosView extends StatefulWidget {
  const ProdutosView({super.key});

  @override
  State<ProdutosView> createState() => _ProdutosViewState();
}

class _ProdutosViewState extends State<ProdutosView> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<ProdutosViewModel>();
      if (vm.query.isNotEmpty) {
        vm.resetBusca(notify: false);
        if (_searchController.text.isNotEmpty) {
          _searchController.clear();
        }
      }
      vm.loadProdutos();
      attachPaginationScrollListener(
        controller: _listScrollController,
        hasMore: () {
          final current = context.read<ProdutosViewModel>();
          return current.query.trim().isNotEmpty
              ? current.hasMoreBusca
              : current.hasMoreProdutos;
        },
        isLoadingMore: () {
          final current = context.read<ProdutosViewModel>();
          return current.query.trim().isNotEmpty
              ? current.isLoadingMoreBusca
              : current.isLoadingMoreProdutos;
        },
        onLoadMore: () {
          final current = context.read<ProdutosViewModel>();
          if (current.query.trim().isNotEmpty) {
            current.loadMoreBusca();
          } else {
            current.loadMoreProdutos();
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
      context.read<ProdutosViewModel>().resetBusca(notify: false);
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
      context.read<ProdutosViewModel>().resetBusca(notify: false);
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
      }
      context.read<ProdutosViewModel>().loadProdutos();
    });
  }

  /// Lista a exibir: sem busca usa produtosTodos; com busca usa produtosBusca.
  List<ProdutoModel> _listaParaExibir(ProdutosViewModel vm, bool isBuscando) {
    if (!isBuscando) return vm.produtosTodos;
    if (vm.stateBusca == ViewState.success) return vm.produtosBusca;
    return vm.produtosBusca.isNotEmpty ? vm.produtosBusca : vm.produtosTodos;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProdutosViewModel>(
      builder: (context, vm, _) {
        final isBuscando = vm.query.trim().isNotEmpty;
        final produtos = _listaParaExibir(vm, isBuscando);
        final loadingLista =
            vm.state == ViewState.loading && vm.produtosTodos.isEmpty;
        final errorLista =
            vm.state == ViewState.error && vm.produtosTodos.isEmpty;

        final countAtual =
            isBuscando ? vm.produtosBusca.length : vm.produtosTodos.length;
        final totalAtual = isBuscando ? vm.totalBusca : vm.totalProdutos;
        final countLabel = totalAtual > countAtual
            ? '$countAtual de $totalAtual produtos'
            : (produtos.length == 1
                ? '1 produto encontrado'
                : '${produtos.length} produtos encontrados');

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
              ProdutoSearchBar(controller: _searchController),
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
                  context,
                  vm,
                  produtos: produtos,
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
    BuildContext context,
    ProdutosViewModel vm, {
    required List<ProdutoModel> produtos,
    required bool isBuscando,
    required bool loadingLista,
    required bool errorLista,
  }) {
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
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => vm.loadProdutos(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (produtos.isEmpty) {
      return _buildEmptyState(context, vm, isBuscando);
    }
    return Scrollbar(
      controller: _listScrollController,
      thumbVisibility: true,
      child: ProdutoList(
        produtos: produtos,
        scrollController: _listScrollController,
        onTap: (p) {
          if (p.idProduto != null) {
            final path = AppRoutes.produtosDetalhesId(p.idProduto!);
            context.read<NavigationController>().registrarRota(path);
            context.go(path);
          }
        },
        footer: ListLoadMoreFooter(
          isLoadingMore: isBuscando
              ? vm.isLoadingMoreBusca
              : vm.isLoadingMoreProdutos,
          hasMore: isBuscando ? vm.hasMoreBusca : vm.hasMoreProdutos,
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ProdutosViewModel vm,
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
                  ? 'Nenhum produto encontrado para esta busca.'
                  : 'Nenhum produto cadastrado.',
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
                  context
                      .read<NavigationController>()
                      .registrarRota(AppRoutes.produtosCriar);
                  context.go(AppRoutes.produtosCriar);
                },
                child: const Text('Cadastrar produto'),
              ),
          ],
        ),
      ),
    );
  }
}
