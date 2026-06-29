import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/core/constants/app_constants.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Rótulo de versão exibido no rodapé da sidebar.
class SidebarVersionLabel extends StatelessWidget {
  const SidebarVersionLabel({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Versão ${AppConstants.appVersion}',
      textAlign: compact ? TextAlign.center : TextAlign.start,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.sidebarTextMuted.withValues(alpha: 0.75),
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
    );
  }
}
