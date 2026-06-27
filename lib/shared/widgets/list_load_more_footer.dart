import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/widgets/app_shimmer.dart';

/// Rodapé de lista com shimmer durante carregamento de mais itens.
class ListLoadMoreFooter extends StatelessWidget {
  const ListLoadMoreFooter({
    super.key,
    required this.isLoadingMore,
    required this.hasMore,
  });

  final bool isLoadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (!isLoadingMore && !hasMore) {
      return const SizedBox(height: AppSpacing.md);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: isLoadingMore
            ? const AppShimmer(width: 120, height: 24)
            : Text(
                'Role para carregar mais',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
      ),
    );
  }
}
