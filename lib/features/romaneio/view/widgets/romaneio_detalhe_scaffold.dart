import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Layout padrão do detalhe do romaneio (padding + largura máxima).
class RomaneioDetalheScaffold extends StatelessWidget {
  const RomaneioDetalheScaffold({
    super.key,
    required this.child,
    this.paddingRight,
  });

  final Widget child;
  final double? paddingRight;

  @override
  Widget build(BuildContext context) {
    final right = paddingRight ?? AppSpacing.lg;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: right,
        top: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
          child: child,
        ),
      ),
    );
  }
}
