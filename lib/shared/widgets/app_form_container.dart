import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Container padrão para formulários: centralizado, maxWidth 700, padding 24,
/// bordas arredondadas, borda sutil, sombra personalizada (profundidade).
/// O scroll fica na página que usa o container.
/// [padding] opcional; se null, usa [AppSpacing.formContainerPadding].
class AppFormContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppFormContainer({
    super.key,
    required this.child,
    this.padding,
  });

  static List<BoxShadow> get _boxShadow => [
        BoxShadow(
          color: AppColors.cardShadowColor,
          blurRadius: AppSpacing.formContainerShadowBlurRadius,
          offset: Offset(0, AppSpacing.formContainerShadowOffsetY),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.sidebarBackground,
            borderRadius: BorderRadius.circular(AppRadius.formContainer),
            border: Border.all(
              color: AppColors.cardBorder,
              width: 1,
            ),
            boxShadow: _boxShadow,
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
