import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';

/// Item de filtro para a linha horizontal (label, selecionado, callback, contador opcional).
class ClientFilterChipItem {
  const ClientFilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;
}

/// Linha horizontal de filtros em formato pill, logo abaixo da barra de busca.
/// Um único filtro ativo por vez; visual integrado ao tema escuro.
class ClientFilterRow extends StatelessWidget {
  const ClientFilterRow({
    super.key,
    required this.items,
  });

  final List<ClientFilterChipItem> items;

  static const double _pillHeight = 34;
  static const double _horizontalPadding = 16;
  static const double _gap = 6;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          _FilterPill(item: items[i], pillRadius: AppRadius.pill),
        ],
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.item, required this.pillRadius});

  final ClientFilterChipItem item;
  final double pillRadius;

  @override
  Widget build(BuildContext context) {
    final isActive = item.isSelected;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(pillRadius),
      child: InkWell(
        onTap: isActive ? null : item.onTap,
        borderRadius: BorderRadius.circular(pillRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: ClientFilterRow._pillHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: ClientFilterRow._horizontalPadding,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(pillRadius),
            border: isActive
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 1,
                  )
                : Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              if (item.count != null) ...[
                const SizedBox(width: 4),
                Text(
                  '(${item.count})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.9)
                        : AppColors.textSecondary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
