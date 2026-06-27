import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_detalhe_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Tabela de produtos agregados do romaneio.
class RomaneioResumoProdutoCard extends StatelessWidget {
  const RomaneioResumoProdutoCard({
    super.key,
    required this.vm,
  });

  final RomaneioDetalheViewModel vm;

  @override
  Widget build(BuildContext context) {
    final produtos = vm.produtosAgregados;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(AppRadius.formContainer),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(0.6),
              2: FlexColumnWidth(1.2),
            },
            border: TableBorder(
              horizontalInside: BorderSide(
                color: AppColors.inputEnabledBorder.withValues(alpha: 0.6),
              ),
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: AppColors.input.withValues(alpha: 0.5),
                ),
                children: [
                  _RomaneioTableCell('Produto', isHeader: true),
                  _RomaneioTableCell('Qtd', isHeader: true),
                  _RomaneioTableCell('Valor', isHeader: true),
                ],
              ),
              ...produtos.map(
                (p) => TableRow(
                  children: [
                    _RomaneioTableCell(p.nome, isHeader: false, maxLines: 2),
                    _RomaneioTableCell('${p.quantidadeTotal}', isHeader: false),
                    _RomaneioTableCell(
                      vm.formatarMoeda(p.subtotalTotal),
                      isHeader: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Total (faturamento): ',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                vm.formatarMoeda(vm.totalFaturado),
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 18,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RomaneioTableCell extends StatelessWidget {
  const _RomaneioTableCell(
    this.text, {
    required this.isHeader,
    this.maxLines = 1,
  });

  final String text;
  final bool isHeader;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.sm,
      ),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: isHeader
            ? AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )
            : AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
      ),
    );
  }
}
