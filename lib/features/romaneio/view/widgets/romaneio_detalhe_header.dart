import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_detalhe_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Cabeçalho do romaneio: número, status e data.
class RomaneioDetalheHeaderCard extends StatelessWidget {
  const RomaneioDetalheHeaderCard({
    super.key,
    required this.vm,
    required this.romaneio,
  });

  final RomaneioDetalheViewModel vm;
  final RomaneioModel romaneio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(AppRadius.formContainer),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vm.textoNumeroRomaneio(romaneio),
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: vm.corStatus(romaneio.status).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: vm.corStatus(romaneio.status).withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Text(
                  romaneio.status.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: vm.corStatus(romaneio.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                vm.dataFormatada(romaneio),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
