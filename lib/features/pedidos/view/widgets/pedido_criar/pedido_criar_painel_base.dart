import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Container padrão dos painéis da tela de criação de pedido.
class PedidoCriarPainelBase extends StatelessWidget {
  const PedidoCriarPainelBase({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: AppColors.cardBoxShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.formContainerPadding),
        child: child,
      ),
    );
  }
}
