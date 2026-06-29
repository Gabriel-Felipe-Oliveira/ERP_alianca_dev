import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/view/widgets/dashboard_comercial_charts_section.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/view/widgets/dashboard_comercial_filters_bar.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/view/widgets/dashboard_comercial_kpi_row.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/view/widgets/dashboard_comercial_pedidos_table.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/view/widgets/dashboard_comercial_rankings_section.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/viewmodel/dashboard_comercial_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/widgets/app_shimmer.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';

class DashboardComercialView extends StatefulWidget {
  const DashboardComercialView({super.key});

  @override
  State<DashboardComercialView> createState() => _DashboardComercialViewState();
}

class _DashboardComercialViewState extends State<DashboardComercialView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DashboardComercialViewModel>().carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardComercialViewModel>();

    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  title: 'Dashboard Comercial',
                  description:
                      'Visão de vendas, pedidos, rankings e últimos pedidos do período.',
                  icon: Icons.insights_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                DashboardComercialFiltersBar(
                  vm: vm,
                  onApply: () => vm.carregar(),
                ),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Material(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(vm.errorMessage!),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: vm.isLoading
                      ? const _LoadingPlaceholder()
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DashboardComercialKpiRow(cards: vm.dados.cards),
                              const SizedBox(height: AppSpacing.lg),
                              DashboardComercialChartsSection(
                                graficos: vm.dados.graficos,
                                agrupamento: vm.agrupamento,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              DashboardComercialRankingsSection(
                                graficos: vm.dados.graficos,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              DashboardComercialPedidosTable(
                                pedidos: vm.dados.ultimosPedidos,
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Row(
          children: [
            Expanded(
              child: AppShimmer(
                width: double.infinity,
                height: 120,
                borderRadius: 16,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppShimmer(
                width: double.infinity,
                height: 120,
                borderRadius: 16,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppShimmer(
                width: double.infinity,
                height: 120,
                borderRadius: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        AppShimmer(width: double.infinity, height: 260, borderRadius: 16),
      ],
    );
  }
}
