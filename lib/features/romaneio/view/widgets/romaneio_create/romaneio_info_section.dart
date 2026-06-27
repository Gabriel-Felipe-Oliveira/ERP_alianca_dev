import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';
import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';

/// Seção: Informações do Romaneio (número badge, data read-only, observação).
class RomaneioInfoSection extends StatelessWidget {
  const RomaneioInfoSection({super.key, required this.vm});

  final RomaneioCriarViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Informações do Romaneio',
          style: AppTextStyles.sectionTitleSecondary,
        ),
        const SizedBox(height: AppSpacing.fieldSpacingCompact),
        _NumeroBadge(
          value: vm.numeroController.text.trim().isEmpty
              ? 'Será atribuído ao salvar'
              : vm.numeroController.text.trim(),
        ),
        const SizedBox(height: AppSpacing.fieldSpacingCompact),
        _ReadOnlyField(
          label: 'Data de Criação',
          value: formatarData(vm.dataCriacao),
        ),
        const SizedBox(height: AppSpacing.fieldSpacingCompact),
        AppTextField(
          label: 'Observação (opcional)',
          controller: vm.observacaoController,
          minLines: 1,
          maxLines: null,
        ),
      ],
    );
  }
}

class _NumeroBadge extends StatelessWidget {
  const _NumeroBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Número do Romaneio',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 4,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.input.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Text(
            value,
            style: AppTextStyles.tag.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.inputPaddingHorizontal,
            vertical: AppSpacing.sm + 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.input.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
