import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Botão primário padronizado do Design System.
/// Se [onPressed] for null e [onDisabledTap] for informado, o botão permanece
/// visualmente desativado mas responde ao toque chamando [onDisabledTap]
/// (ex.: exibir quais campos faltam preencher).
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onDisabledTap;
  final bool isLoading;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.onDisabledTap,
    this.isLoading = false,
  });

  bool get _enabled => onPressed != null;
  VoidCallback? get _effectiveOnPressed {
    if (isLoading) return null;
    if (onPressed != null) return onPressed;
    return onDisabledTap;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: _effectiveOnPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (!_enabled || states.contains(WidgetState.disabled)) {
                return AppColors.sidebarItemBackground;
              }
              return AppColors.primary;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (!_enabled || states.contains(WidgetState.disabled)) {
                return AppColors.textSecondary;
              }
              return AppColors.textPrimary;
            },
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.textPrimary.withValues(alpha: 0.12);
              }
              return null;
            },
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                ),
              )
            : Text(
                label,
                style: AppTextStyles.button,
              ),
      ),
    );
  }
}
