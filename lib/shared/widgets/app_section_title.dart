import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Título de seção dentro de formulários (ex: "Dados Gerais", "Endereço", "Status").
class AppSectionTitle extends StatelessWidget {
  final String title;

  const AppSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.sectionTitle,
      ),
    );
  }
}
