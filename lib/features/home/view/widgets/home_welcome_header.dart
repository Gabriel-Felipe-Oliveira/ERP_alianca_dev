import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:erp_alianca_dev/features/home/utils/home_welcome_messages.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Cabeçalho de boas-vindas exclusivo da Home.
class HomeWelcomeHeader extends StatelessWidget {
  const HomeWelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final nome = context.select<AuthService, String?>(
      (auth) => auth.usuario?.nome,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HomeIconBadge(),
          const SizedBox(height: AppSpacing.md),
          Text(
            HomeWelcomeMessages.greeting(nome),
            textAlign: TextAlign.center,
            style: AppTextStyles.heading1.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              HomeWelcomeMessages.subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.pageHeaderDescription.copyWith(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeIconBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.9),
            AppColors.primaryLight.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.home_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
