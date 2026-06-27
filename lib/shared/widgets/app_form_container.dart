import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Container padrão para formulários: centralizado, maxWidth 700, padding 24,
/// bordas arredondadas, borda sutil, sombra personalizada (profundidade).
class AppFormContainer extends StatelessWidget {
  const AppFormContainer({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.formContainer),
            border: Border.all(
              color: AppColors.cardBorder,
              width: 1,
            ),
            boxShadow: AppColors.cardBoxShadow,
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.formContainerPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}
