import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/routes/app_router.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produtos_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/viewmodels/navigation_controller.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/pagination_scroll.dart';
import 'package:erp_alianca_dev/shared/widgets/app_shimmer.dart';
import 'package:erp_alianca_dev/shared/widgets/list_load_more_footer.dart';
import 'package:erp_alianca_dev/shared/widgets/compact_search_select.dart';
import 'package:erp_alianca_dev/shared/widgets/listagem_list_card.dart';

/// Formata preço para exibição (ex.: 29.9 → "29,90").
String _formatarPreco(double preco) {
  return preco.toStringAsFixed(2).replaceAll('.', ',');
}

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
        hasMore: () => context.read<ProdutosViewModel>().hasMoreProdutos,
        isLoadingMore: () =>
            context.read<ProdutosViewModel>().isLoadingMoreProdutos,
        onLoadMore: () => context.read<ProdutosViewModel>().loadMoreProdutos(),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ProdutosViewModel>(
      builder: (context, vm, _) {
        final produtos = vm.produtosTodos;
        final loadingLista = vm.state == ViewState.loading && vm.produtosTodos.isEmpty;
        final errorLista = vm.state == ViewState.error && vm.produtosTodos.isEmpty;

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
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 16, 8),
                child: CompactSearchSelect<ProdutoModel>(
                  controller: _searchController,
                  hintText: 'Buscar produtos por nome...',
                  onSearch: () => vm.buscarPorNome(),
                  onChanged: (value) => vm.query = value,
                  onFocus: () => vm.buscarPorNome(),
                  isLoading: vm.stateBusca == ViewState.loading,
                  items: vm.produtosBusca,
                  itemBuilder: (context, p) => _buildProdutoSearchRow(p),
                  onItemSelected: (p) {
                    vm.limparBusca();
                    if (p.idProduto != null) {
                      context.read<NavigationController>().registrarRota(AppRoutes.produtos);
                      context.read<NavigationController>().registrarRota(AppRoutes.produtosDetalhesId(p.idProduto!));
                      context.go(AppRoutes.produtosDetalhesId(p.idProduto!));
                    }
                  },
                  errorMessage: vm.stateBusca == ViewState.error ? 'Erro ao buscar. Tente novamente.' : null,
                  maxListHeight: 280,
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  vm.totalProdutos > produtos.length
                      ? '${produtos.length} de ${vm.totalProdutos} produtos'
                      : (produtos.length == 1
                          ? '1 produto encontrado'
                          : '${produtos.length} produtos encontrados'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              Expanded(
                child: _buildMainContent(context, vm, produtos, loadingLista, errorLista),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProdutoSearchRow(ProdutoModel p) {
    return Row(
      children: [
        Expanded(
          child: Text(
            p.nome,
            style: AppTextStyles.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          'R\$ ${_formatarPreco(p.preco)}',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    ProdutosViewModel vm,
    List<ProdutoModel> produtos,
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
                onPressed: () => vm.loadProdutos(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (produtos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nenhum produto cadastrado.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () {
                  context.read<NavigationController>().registrarRota(AppRoutes.produtosCriar);
                  context.go(AppRoutes.produtosCriar);
                },
                child: const Text('Cadastrar produto'),
              ),
            ],
          ),
        ),
      );
    }
    return Scrollbar(
      controller: _listScrollController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _listScrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: produtos.length + 1,
        separatorBuilder: (_, index) {
          if (index >= produtos.length - 1) {
            return const SizedBox.shrink();
          }
          return const SizedBox(height: AppSpacing.sm);
        },
        itemBuilder: (context, index) {
          if (index == produtos.length) {
            return ListLoadMoreFooter(
              isLoadingMore: vm.isLoadingMoreProdutos,
              hasMore: vm.hasMoreProdutos,
            );
          }
          final p = produtos[index];
          return _ProdutoListItem(
            produto: p,
            onTap: () {
              if (p.idProduto != null) {
                final path = AppRoutes.produtosDetalhesId(p.idProduto!);
                context.read<NavigationController>().registrarRota(path);
                context.go(path);
              }
            },
          );
        },
      ),
    );
  }
}

class _ProdutoListItem extends StatelessWidget {
  const _ProdutoListItem({
    required this.produto,
    this.onTap,
  });

  final ProdutoModel produto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final codigo = produto.idProduto != null
        ? '#${produto.idProduto!.toString().padLeft(5, '0')}'
        : '—';
    return ListagemListItem(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              codigo,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              produto.nome,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'R\$ ${_formatarPreco(produto.preco)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
