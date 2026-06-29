import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/model/dashboard_comercial_model.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/utils/dashboard_comercial_formatters.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

class DashboardComercialBarChart extends StatelessWidget {
  const DashboardComercialBarChart({
    super.key,
    required this.title,
    required this.series,
    required this.agrupamento,
    required this.accent,
    this.isCurrency = true,
  });

  final String title;
  final List<DashboardPeriodoValor> series;
  final String agrupamento;
  final Color accent;
  final bool isCurrency;

  @override
  Widget build(BuildContext context) {
    final maxValue = series.fold<double>(
      0,
      (prev, item) => item.total > prev ? item.total : prev,
    );

    return _DashboardPanel(
      title: title,
      child: series.isEmpty
          ? const _EmptyChartMessage()
          : SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final item in series) ...[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _BarColumn(
                          label: formatarPeriodoLabel(item.periodo, agrupamento),
                          valueLabel: isCurrency
                              ? formatarMoedaDashboard(item.total)
                              : formatarNumeroDashboard(item.total),
                          fraction: maxValue > 0 ? item.total / maxValue : 0,
                          accent: accent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.label,
    required this.valueLabel,
    required this.fraction,
    required this.accent,
  });

  final String label;
  final String valueLabel;
  final double fraction;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          valueLabel,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction.clamp(0.08, 1.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      accent,
                      accent.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.formContainer),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardBoxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _EmptyChartMessage extends StatelessWidget {
  const _EmptyChartMessage();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Text(
          'Sem dados no período selecionado.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class DashboardComercialChartsSection extends StatelessWidget {
  const DashboardComercialChartsSection({
    super.key,
    required this.graficos,
    required this.agrupamento,
  });

  final DashboardComercialGraficos graficos;
  final String agrupamento;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 900;
        final charts = [
          DashboardComercialBarChart(
            title: 'Vendas por período',
            series: graficos.vendasPorPeriodo,
            agrupamento: agrupamento,
            accent: AppColors.primary,
            isCurrency: true,
          ),
          DashboardComercialBarChart(
            title: 'Pedidos por período',
            series: graficos.pedidosPorPeriodo,
            agrupamento: agrupamento,
            accent: const Color(0xFF10B981),
            isCurrency: false,
          ),
        ];

        if (stacked) {
          return Column(
            children: [
              charts[0],
              const SizedBox(height: AppSpacing.md),
              charts[1],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: charts[0]),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: charts[1]),
          ],
        );
      },
    );
  }
}
