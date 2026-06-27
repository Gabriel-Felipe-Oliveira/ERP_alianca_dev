import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_campo_logistica.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_detalhe_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Resumo da carga: volumes, ocupação e total faturado.
class RomaneioResumoCargaCard extends StatelessWidget {
  const RomaneioResumoCargaCard({
    super.key,
    required this.vm,
  });

  final RomaneioDetalheViewModel vm;

  @override
  Widget build(BuildContext context) {
    final percentual = vm.percentualOcupacao;
    final barraMaiorQue90 = percentual > 90;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(AppRadius.formContainer),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo da carga',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RomaneioCampoLogistica(
                label: 'Volume total',
                value: '${vm.totalVolumes} vols',
              ),
              RomaneioCampoLogistica(
                label: 'Capacidade caminhão',
                value: '$capacidadeCaminhaoVolumes vols',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ocupação',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${percentual.toStringAsFixed(1)}%',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentual > 100
                  ? 1.0
                  : (percentual / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                barraMaiorQue90 ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Total faturado',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            vm.formatarMoeda(vm.totalFaturado),
            style: AppTextStyles.heading2.copyWith(
              fontSize: 26,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
