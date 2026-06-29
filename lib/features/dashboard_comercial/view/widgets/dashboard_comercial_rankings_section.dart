import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/model/dashboard_comercial_model.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/utils/dashboard_comercial_formatters.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

class DashboardComercialRankingsSection extends StatelessWidget {
  const DashboardComercialRankingsSection({
    super.key,
    required this.graficos,
  });

  final DashboardComercialGraficos graficos;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 1100;
        final panels = [
          _RankingPanel(
            title: 'Produtos mais vendidos',
            icon: Icons.emoji_events_outlined,
            emptyMessage: 'Nenhum produto vendido no período.',
            rows: [
              for (var i = 0; i < graficos.produtosMaisVendidos.length; i++)
                _RankingRowData(
                  position: i + 1,
                  title: graficos.produtosMaisVendidos[i].produto,
                  subtitle:
                      'Qtd: ${formatarNumeroDashboard(graficos.produtosMaisVendidos[i].quantidade ?? 0)}',
                  value: formatarMoedaDashboard(
                    graficos.produtosMaisVendidos[i].valorTotal,
                  ),
                  onTap: () => context.go(
                    AppRoutes.produtosDetalhesId(
                      graficos.produtosMaisVendidos[i].idProduto,
                    ),
                  ),
                ),
            ],
          ),
          _RankingPanel(
            title: 'Maior faturamento',
            icon: Icons.attach_money,
            emptyMessage: 'Sem faturamento por produto no período.',
            rows: [
              for (var i = 0; i < graficos.produtosMaiorFaturamento.length; i++)
                _RankingRowData(
                  position: i + 1,
                  title: graficos.produtosMaiorFaturamento[i].produto,
                  subtitle: 'ID ${graficos.produtosMaiorFaturamento[i].idProduto}',
                  value: formatarMoedaDashboard(
                    graficos.produtosMaiorFaturamento[i].valorTotal,
                  ),
                  onTap: () => context.go(
                    AppRoutes.produtosDetalhesId(
                      graficos.produtosMaiorFaturamento[i].idProduto,
                    ),
                  ),
                ),
            ],
          ),
          _RankingPanel(
            title: 'Clientes que mais compraram',
            icon: Icons.people_alt_outlined,
            emptyMessage: 'Nenhum cliente com compras no período.',
            rows: [
              for (var i = 0; i < graficos.clientesMaisCompraram.length; i++)
                _RankingRowData(
                  position: i + 1,
                  title: graficos.clientesMaisCompraram[i].nomeExibicao,
                  subtitle:
                      '${graficos.clientesMaisCompraram[i].totalPedidos} pedido(s)',
                  value: formatarMoedaDashboard(
                    graficos.clientesMaisCompraram[i].valorTotal,
                  ),
                  onTap: () => context.go(
                    AppRoutes.clientesDetalhesId(
                      graficos.clientesMaisCompraram[i].idCliente,
                    ),
                  ),
                ),
            ],
          ),
        ];

        if (stacked) {
          return Column(
            children: [
              for (var i = 0; i < panels.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                panels[i],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: panels[0]),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: panels[1]),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: panels[2]),
          ],
        );
      },
    );
  }
}

class _RankingRowData {
  const _RankingRowData({
    required this.position,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onTap,
  });

  final int position;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback? onTap;
}

class _RankingPanel extends StatelessWidget {
  const _RankingPanel({
    required this.title,
    required this.icon,
    required this.emptyMessage,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final String emptyMessage;
  final List<_RankingRowData> rows;

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
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (rows.isEmpty)
            Text(
              emptyMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ...rows.map((row) => _RankingRow(row: row)),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.row});

  final _RankingRowData row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.listagemItemBackground,
        borderRadius: BorderRadius.circular(AppSpacing.listagemItemBorderRadius),
        child: InkWell(
          onTap: row.onTap,
          hoverColor: AppColors.listagemItemHover,
          borderRadius:
              BorderRadius.circular(AppSpacing.listagemItemBorderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _PositionBadge(position: row.position),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        row.subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  row.value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
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

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({required this.position});

  final int position;

  @override
  Widget build(BuildContext context) {
    final color = switch (position) {
      1 => const Color(0xFFF59E0B),
      2 => const Color(0xFF94A3B8),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.textSecondary,
    };

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$position',
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
