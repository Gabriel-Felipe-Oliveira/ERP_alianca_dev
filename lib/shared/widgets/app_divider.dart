import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Divisor padrão do app (cor e espessura centralizadas).
class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.sidebarDivider,
      height: 2,
      thickness: 2,
    );
  }
}
