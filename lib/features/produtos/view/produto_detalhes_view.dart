import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/produtos/view/widgets/produto_detalhe/produto_detalhe_form_body.dart';
import 'package:erp_alianca_dev/features/produtos/view/widgets/produto_detalhe/produto_detalhe_status_body.dart';
import 'package:erp_alianca_dev/features/produtos/view/widgets/produto_detalhe/produto_detalhe_tool_panel.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produto_editar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Tela de detalhes do produto. Busca os dados na API usando o id da rota.
/// Mesmo padrão da tela de detalhes do cliente: LayoutBuilder → Stack (scroll + painel).
class ProdutoDetalhesView extends StatefulWidget {
  const ProdutoDetalhesView({super.key});

  @override
  State<ProdutoDetalhesView> createState() => _ProdutoDetalhesViewState();
}

class _ProdutoDetalhesViewState extends State<ProdutoDetalhesView>
    with SingleTickerProviderStateMixin {
  static const Duration _entranceDuration = Duration(milliseconds: 950);

  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;
  late final Animation<double> _entranceScale;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    );
    final curve = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.linear,
    );
    _entranceFade = curve;
    _entranceScale = Tween<double>(begin: 0.88, end: 1.0).animate(curve);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProdutoEditarViewModel>(
      builder: (context, vm, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < AppSpacing.toolPanelBreakpoint;
            final rightPadding = compact
                ? AppSpacing.toolPanelWidthCompact + AppSpacing.lg + AppSpacing.sm
                : AppSpacing.toolPanelWidth + AppSpacing.lg * 2;

            return Stack(
              children: [
                RepaintBoundary(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: rightPadding,
                        vertical: AppSpacing.lg,
                      ),
                      child: Center(
                        child: ScaleTransition(
                          scale: _entranceScale,
                          alignment: Alignment.center,
                          child: FadeTransition(
                            opacity: _entranceFade,
                            child: _buildBody(vm),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: AppSpacing.lg,
                  top: 0,
                  bottom: 0,
                  child: RepaintBoundary(
                    child: Center(
                      child: ProdutoDetalheToolPanel(vm: vm, compact: compact),
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

  Widget _buildBody(ProdutoEditarViewModel vm) {
    if (vm.isLoading) {
      return const ProdutoDetalheStatusBody.loading();
    }
    if (vm.loadError != null) {
      return ProdutoDetalheStatusBody.error(
        loadError: vm.loadError!,
        onRetry: vm.recarregar,
      );
    }
    return ProdutoDetalheFormBody(vm: vm);
  }
}
