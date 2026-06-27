import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_detalhe_actions.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_detalhe_edicao_body.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_detalhe_header.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_detalhe_logistica_card.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_detalhe_scaffold.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_pedidos_list_card.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_resumo_carga_card.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_resumo_produto_card.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_toolbar_panel.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_detalhe_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_shimmer.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';

/// Tela de detalhe do romaneio. Apenas UI; dados e formatações vêm do ViewModel.
class RomaneioDetalhesView extends StatefulWidget {
  const RomaneioDetalhesView({super.key});

  @override
  State<RomaneioDetalhesView> createState() => _RomaneioDetalhesViewState();
}

class _RomaneioDetalhesViewState extends State<RomaneioDetalhesView> {
  String? _toolbarActionInProgress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RomaneioDetalheViewModel>().loadRomaneio();
    });
  }

  void _setToolbarProgress(String? label) {
    if (!mounted) return;
    setState(() => _toolbarActionInProgress = label);
  }

  Future<void> _runComProgresso(
    String label,
    Future<void> Function() action,
  ) async {
    _setToolbarProgress(label);
    try {
      await action();
    } finally {
      _setToolbarProgress(null);
    }
  }

  Future<void> _faturar(
    BuildContext context,
    RomaneioDetalheViewModel vm,
  ) async {
    await _runComProgresso('Faturar', () async {
      final results = await vm.exportarFaturar(context);
      if (!context.mounted) return;
      for (final result in results) {
        if (result.message == null) continue;
        showAppToast(
          context,
          message: result.message!,
          isError: result.isError,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RomaneioDetalheViewModel>(
      builder: (context, vm, _) {
        if (vm.state == ViewState.loading && vm.romaneio == null) {
          return RomaneioDetalheScaffold(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Detalhe do Romaneio',
                  onBack: () => context.go(AppRoutes.romaneio),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppShimmer(width: double.infinity, height: 120),
              ],
            ),
          );
        }

        if (vm.state == ViewState.error && vm.romaneio == null) {
          return RomaneioDetalheScaffold(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Detalhe do Romaneio',
                  onBack: () => context.go(AppRoutes.romaneio),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vm.errorMessage,
                        style: AppTextStyles.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: () => vm.loadRomaneio(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final r = vm.romaneio;
        if (r == null) return const SizedBox.shrink();

        if (vm.isEditMode) {
          return RomaneioDetalheScaffold(
            child: RomaneioDetalheEdicaoBody(vm: vm),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < AppSpacing.toolPanelBreakpoint;
            final rightPadding = compact
                ? AppSpacing.toolPanelWidthCompact + AppSpacing.lg + AppSpacing.sm
                : AppSpacing.toolPanelWidth + AppSpacing.lg * 2;

            return Stack(
              children: [
                RomaneioDetalheScaffold(
                  paddingRight: rightPadding,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: 'Detalhe do Romaneio',
                              onBack: () => context.go(AppRoutes.romaneio),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            RomaneioDetalheHeaderCard(vm: vm, romaneio: r),
                            const SizedBox(height: AppSpacing.lg),
                            RomaneioDetalheLogisticaCard(vm: vm, romaneio: r),
                            const SizedBox(height: AppSpacing.lg),
                            RomaneioPedidosListCard(vm: vm),
                            const SizedBox(height: AppSpacing.lg),
                            RomaneioResumoCargaCard(vm: vm),
                            const SizedBox(height: AppSpacing.xl),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: AppSpacing.xs,
                                bottom: AppSpacing.sm,
                              ),
                              child: Text(
                                'Resumo por produto',
                                style: AppTextStyles.sectionTitle,
                              ),
                            ),
                            if (vm.loadingPedidos)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.lg,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              )
                            else if (vm.produtosAgregados.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.lg,
                                ),
                                child: Text(
                                  'Nenhum produto carregado.',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              )
                            else
                              RomaneioResumoProdutoCard(vm: vm),
                          ],
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xxl),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: AppSpacing.lg,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: RomaneioToolbarPanel(
                      vm: vm,
                      romaneio: r,
                      compact: compact,
                      actionInProgress: _toolbarActionInProgress,
                      onFaturar: () => _faturar(context, vm),
                      onVisualizarPdf: () => _runComProgresso(
                        'Visualizar PDF',
                        () => vm.exportarVisualizarPdf(context),
                      ),
                      onGerarPdf: () => _runComProgresso(
                        'Gerar PDF',
                        () => vm.exportarSalvarPdf(context),
                      ),
                      onEditar: () => vm.enterEditMode(),
                      onCancelar: () => romaneioConfirmarCancelar(
                        context,
                        vm,
                        _setToolbarProgress,
                      ),
                      onExcluir: () => romaneioConfirmarExcluir(
                        context,
                        vm,
                        _setToolbarProgress,
                      ),
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
