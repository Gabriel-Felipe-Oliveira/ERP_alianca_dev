import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Cabeçalho de seção: título com barra lateral, descrição opcional, em container destacado.
/// Se [onBack] for informado, exibe botão de voltar à esquerda (telas de criar/detalhe).
class SectionHeader extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onBack;

  const SectionHeader({
    super.key,
    required this.title,
    this.description,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
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
            ),
          ),
        ),
      ),
    );
  }
}
