import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_interactive.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_logout_button.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_user_avatar.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_version_label.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_theme_mode_toggle.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tooltip.dart';

/// Rodapé da sidebar: dados do usuário, alternância de tema, logout e versão.
class SidebarFooter extends StatelessWidget {
  const SidebarFooter({super.key, required this.compactLayout});

  final bool compactLayout;

  Future<void> _logout(BuildContext context, AuthService auth) async {
    final router = GoRouter.of(context);
    await auth.logout();
    if (!context.mounted) return;
    router.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final usuario = auth.usuario;

    if (compactLayout) {
      return Column(
        children: [
          const SidebarSubtleDivider(),
          if (usuario != null) ...[
            AppTooltip(
              message: '${usuario.nome}\n${usuario.email}',
              child: SidebarUserAvatar(nome: usuario.nome, radius: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const AppThemeModeToggle(compact: true),
          const SizedBox(height: AppSpacing.xs),
          SidebarLogoutButton(
            compact: true,
            onPressed: () => _logout(context, auth),
          ),
          const SidebarSubtleDivider(),
          const SidebarVersionLabel(compact: true),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SidebarSubtleDivider(),
        if (usuario != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SidebarUserAvatar(nome: usuario.nome),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.sidebarTextActive,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      usuario.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.sidebarTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const AppThemeModeToggle(),
        SidebarLogoutButton(
          onPressed: () => _logout(context, auth),
        ),
        const SidebarSubtleDivider(),
        const SidebarVersionLabel(),
      ],
    );
  }
}
