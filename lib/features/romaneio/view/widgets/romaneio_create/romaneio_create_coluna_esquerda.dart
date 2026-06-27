import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/motorista_section.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_create_section_card.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_info_section.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_resumo_card.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

class RomaneioCreateColunaEsquerdaContent extends StatelessWidget {
  const RomaneioCreateColunaEsquerdaContent({super.key, required this.vm});

  final RomaneioCriarViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RomaneioCreateSectionCard(child: RomaneioInfoSection(vm: vm)),
        const SizedBox(height: AppSpacing.sectionSpacingCompact),
        RomaneioCreateSectionCard(child: MotoristaSection(vm: vm)),
        const SizedBox(height: AppSpacing.sectionSpacingCompact),
        Text(
          'Resumo',
          style: AppTextStyles.sectionTitleSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        RomaneioResumoCard(vm: vm),
        if (vm.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(vm.errorMessage!, style: AppTextStyles.error),
        ],
      ],
    );
  }
}
