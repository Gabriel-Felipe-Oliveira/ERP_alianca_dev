import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_input_type.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';

/// Seção: Tipo de Motorista (radio buttons) + Nome/Placa se Próprio.
class MotoristaSection extends StatelessWidget {
  const MotoristaSection({super.key, required this.vm});

  final RomaneioCriarViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Motorista',
          style: AppTextStyles.sectionTitleSecondary,
        ),
        const SizedBox(height: AppSpacing.fieldSpacingCompact),
        RadioGroup<TipoMotorista>(
          groupValue: vm.tipoMotorista,
          onChanged: (value) {
            if (value != null) vm.setTipoMotorista(value);
          },
          child: Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<TipoMotorista>(
                    value: TipoMotorista.proprio,
                    activeColor: AppColors.primary,
                  ),
                  Text(
                    TipoMotorista.proprio.label,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<TipoMotorista>(
                    value: TipoMotorista.agregado,
                    activeColor: AppColors.primary,
                  ),
                  Text(
                    TipoMotorista.agregado.label,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (vm.tipoMotorista == TipoMotorista.proprio) ...[
          const SizedBox(height: AppSpacing.fieldSpacingCompact),
          AppTextField(
            label: 'Nome do Motorista',
            controller: vm.nomeMotoristaController,
          ),
          const SizedBox(height: AppSpacing.fieldSpacingCompact),
          AppTextField(
            label: 'Placa do Veículo (opcional)',
            controller: vm.placaVeiculoController,
            type: AppInputType.placaVeiculo,
          ),
        ],
      ],
    );
  }
}
