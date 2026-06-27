import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_input_type.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';

/// Campo de telefone em dois blocos: DD (2 dígitos) e Número (9 dígitos).
class AppTelefoneField extends StatelessWidget {
  const AppTelefoneField({
    super.key,
    required this.ddController,
    required this.numeroController,
    this.enabled = true,
    this.isDDModified = false,
    this.isNumeroModified = false,
  });

  final TextEditingController ddController;
  final TextEditingController numeroController;
  final bool enabled;
  final bool isDDModified;
  final bool isNumeroModified;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: AppTextField(
            label: 'DD',
            controller: ddController,
            type: AppInputType.telefoneDD,
            enabled: enabled,
            isModified: isDDModified,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 3,
          child: AppTextField(
            label: 'Número',
            controller: numeroController,
            type: AppInputType.telefoneNumero,
            enabled: enabled,
            isModified: isNumeroModified,
          ),
        ),
      ],
    );
  }
}
