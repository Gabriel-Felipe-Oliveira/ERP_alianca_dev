import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_router.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/pagination_scroll.dart';
import 'package:erp_alianca_dev/shared/widgets/app_shimmer.dart';
import 'package:erp_alianca_dev/shared/widgets/list_load_more_footer.dart';
import 'package:erp_alianca_dev/shared/widgets/listagem_list_card.dart';

/// Formata valor em moeda (R$ 1.234,56).
String _formatarMoeda(double value) {
  return NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$ ',
    decimalDigits: 2,
  ).format(value);
}

/// Largura fixa da coluna Romaneio.
const double _kRomaneioColumnWidth = 100;

/// Colunas do cabeçalho/rodapé da listagem de romaneios.
const List<ListagemListColumnSpec> _kRomaneioListColumns = [
  ListagemListColumnSpec(label: 'Romaneio', width: _kRomaneioColumnWidth),
  ListagemListColumnSpec(label: 'Motorista', flex: 1),
  ListagemListColumnSpec(label: 'Faturamento', flex: 0),
];

/// Tela de listagem de romaneios. Padrão igual a cliente/listagem.
class RomaneioView extends StatefulWidget {
  const RomaneioView({super.key});

  @override
  State<RomaneioView> createState() => _RomaneioViewState();
}

class _RomaneioViewState extends State<RomaneioView> with RouteAware {
  final ScrollController _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _recarregarRomaneios();
      attachPaginationScrollListener(
        controller: _listScrollController,
        hasMore: () => context.read<RomaneioViewModel>().hasMoreRomaneios,
        isLoadingMore: () =>
            context.read<RomaneioViewModel>().isLoadingMoreRomaneios,
        onLoadMore: () =>
            context.read<RomaneioViewModel>().loadMoreRomaneios(),
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
      if (mounted) _recarregarRomaneios();
    });
  }

  void _recarregarRomaneios() {
    context.read<RomaneioViewModel>().loadRomaneios();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RomaneioViewModel>(
      builder: (context, vm, _) {
        final lista = vm.romaneios;
        final loadingLista = vm.state == ViewState.loading && vm.romaneios.isEmpty;
        final errorLista = vm.state == ViewState.error && vm.romaneios.isEmpty;

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
                  ...kRomaneioStatusFiltros.map((f) {
                    final isSelected = vm.statusFiltro == f.value;
                    return FilterChip(
                      label: Text(f.label),
                      selected: isSelected,
                      onSelected: (_) {
                        vm.setStatusFiltro(f.value);
                        vm.loadRomaneios();
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
                      ? '1 romaneio encontrado'
                      : '${lista.length} romaneios encontrados',
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
    RomaneioViewModel vm,
    List<RomaneioModel> lista,
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
                onPressed: () => vm.loadRomaneios(),
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
                'Nenhum romaneio encontrado.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.romaneioCriar),
                icon: const Icon(Icons.add),
                label: const Text('Criar Romaneio'),
              ),
            ],
          ),
        ),
      );
    }
    final totalGeral = vm.totalFaturadoListagem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListagemListHeader(columns: _kRomaneioListColumns),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: Scrollbar(
            controller: _listScrollController,
            thumbVisibility: true,
            child: ListView.separated(
              controller: _listScrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              itemCount: lista.length + 1,
              separatorBuilder: (_, index) {
                if (index >= lista.length - 1) {
                  return const SizedBox.shrink();
                }
                return const SizedBox(height: AppSpacing.sm);
              },
              itemBuilder: (context, index) {
                if (index == lista.length) {
                  return ListLoadMoreFooter(
                    isLoadingMore: vm.isLoadingMoreRomaneios,
                    hasMore: vm.hasMoreRomaneios,
                  );
                }
                final r = lista[index];
                return _RomaneioListItem(
                  romaneio: r,
                  onTap: r.id != null
                      ? () => context.go(AppRoutes.romaneioDetalhesId(r.id!))
                      : null,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ListagemListFooter(
          columns: _kRomaneioListColumns,
          lastColumnText: 'Total: ${_formatarMoeda(totalGeral)}',
        ),
      ],
    );
  }
}

class _RomaneioListItem extends StatelessWidget {
  const _RomaneioListItem({required this.romaneio, this.onTap});

  final RomaneioModel romaneio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final numeroTexto = RomaneioModel.nomeExibicao(romaneio);
    final motoristaTexto = (romaneio.nomeMotorista?.trim().isNotEmpty == true)
        ? romaneio.nomeMotorista!.trim()
        : 'Motorista não informado';
    return ListagemListItem(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: _kRomaneioColumnWidth,
            child: Text(
              numeroTexto,
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
              motoristaTexto,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Faturado: ${_formatarMoeda(romaneio.totalFaturado)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
