import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/model/dashboard_comercial_model.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/utils/dashboard_comercial_formatters.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

class DashboardComercialKpiCard extends StatelessWidget {
  const DashboardComercialKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.formContainer),
        side: BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const Spacer(),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardComercialKpiRow extends StatelessWidget {
  const DashboardComercialKpiRow({super.key, required this.cards});

  final DashboardComercialCards cards;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        label: 'Total em vendas',
        value: formatarMoedaDashboard(cards.totalVendas),
        icon: Icons.payments_outlined,
        color: const Color(0xFF3B82F6),
      ),
      (
        label: 'Pedidos',
        value: formatarNumeroDashboard(cards.totalPedidos),
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF10B981),
      ),
      (
        label: 'Ticket médio',
        value: formatarMoedaDashboard(cards.ticketMedio),
        icon: Icons.trending_up,
        color: const Color(0xFFF59E0B),
      ),
      (
        label: 'Produtos vendidos',
        value: formatarNumeroDashboard(cards.totalProdutosVendidos),
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF8B5CF6),
      ),
      (
        label: 'Clientes compradores',
        value: formatarNumeroDashboard(cards.totalClientesEmpresasCompradoras),
        icon: Icons.people_outline,
        color: const Color(0xFFEC4899),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossCount = width >= 1200
            ? 5
            : width >= 900
                ? 3
                : width >= 560
                    ? 2
                    : 1;
        final itemWidth = (width - (crossCount - 1) * AppSpacing.md) / crossCount;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final item in items)
              SizedBox(
                width: crossCount == 1 ? width : itemWidth,
                child: DashboardComercialKpiCard(
                  label: item.label,
                  value: item.value,
                  icon: item.icon,
                  accent: item.color,
                ),
              ),
          ],
        );
      },
    );
  }
}
