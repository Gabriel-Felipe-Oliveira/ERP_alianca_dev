import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Cabeçalho de página: título com barra lateral ou modo compacto (ícone + título).
/// Se [onBack] for informado, exibe botão de voltar à esquerda (telas de criar/detalhe).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.onBack,
  });

  final String title;
  final String? description;
  final IconData? icon;
  final VoidCallback? onBack;

  bool get _compacto => icon != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: _compacto ? 0 : AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _compacto ? _buildCompacto(context) : _buildPadrao(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCompacto(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (onBack != null) ...[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            style: IconButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
            ),
            tooltip: 'Voltar',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPadrao(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (onBack != null) ...[
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  style: IconButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  tooltip: 'Voltar',
                ),
                const SizedBox(width: 4),
              ],
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.pageHeaderTitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                description!,
                style: AppTextStyles.pageHeaderDescription,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
