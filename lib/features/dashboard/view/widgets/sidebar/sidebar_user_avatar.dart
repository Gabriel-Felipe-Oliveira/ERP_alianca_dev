import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Avatar circular com a inicial do nome do usuário.
class SidebarUserAvatar extends StatelessWidget {
  const SidebarUserAvatar({super.key, required this.nome, this.radius = 18});

  final String nome;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = nome.isNotEmpty ? nome.substring(0, 1).toUpperCase() : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.sidebarDivider,
      child: Text(
        initial,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.sidebarTextActive,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.85,
        ),
      ),
    );
  }
}
