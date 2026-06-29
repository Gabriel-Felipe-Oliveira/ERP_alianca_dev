import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/model/dashboard_comercial_model.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/utils/dashboard_comercial_formatters.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

class DashboardComercialPedidosTable extends StatelessWidget {
  const DashboardComercialPedidosTable({
    super.key,
    required this.pedidos,
  });

  final List<DashboardUltimoPedido> pedidos;

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
              Icon(Icons.history, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Últimos pedidos',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (pedidos.isEmpty)
            Text(
              'Nenhum pedido recente no período.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            Column(
              children: [
                _TableHeader(),
                const SizedBox(height: AppSpacing.xs),
                for (final pedido in pedidos) _PedidoRow(pedido: pedido),
              ],
            ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.listagemHeaderGradientStart,
            AppColors.listagemHeaderGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.listagemItemBorderRadius),
      ),
      child: Row(
        children: [
          _HeaderCell('Pedido', flex: 1),
          _HeaderCell('Data', flex: 1),
          _HeaderCell('Status', flex: 1),
          _HeaderCell('Valor', flex: 1, align: TextAlign.end),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {required this.flex, this.align = TextAlign.start});

  final String label;
  final int flex;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _PedidoRow extends StatelessWidget {
  const _PedidoRow({required this.pedido});

  final DashboardUltimoPedido pedido;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: AppColors.listagemItemBackground,
        borderRadius: BorderRadius.circular(AppSpacing.listagemItemBorderRadius),
        child: InkWell(
          onTap: () => context.go(AppRoutes.pedidosDetalhesId(pedido.idPedido)),
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
                Expanded(
                  flex: 1,
                  child: Text(
                    '#${pedido.idPedido}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    pedido.dataPedido,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _StatusChip(status: pedido.status),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    formatarMoedaDashboard(pedido.valorTotal),
                    textAlign: TextAlign.end,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'concluido' => const Color(0xFF10B981),
      'cancelado' => const Color(0xFFEF4444),
      'organizado' => const Color(0xFF3B82F6),
      'confirmado' => const Color(0xFF8B5CF6),
      _ => AppColors.textSecondary,
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          labelStatusPedido(status),
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
