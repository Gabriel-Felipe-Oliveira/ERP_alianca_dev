import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Especificação de um item de filtro na sidebar (label, selecionado, ícone, callback).
class ListagemFiltroItem {
  const ListagemFiltroItem({
    required this.label,
    required this.isSelected,
    this.icon = Icons.filter_list,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final IconData icon;
  final VoidCallback? onTap;
}

/// Sidebar de filtros reutilizável (Produto, Pedido, Cliente, etc.).
/// Visual integrado ao painel: mesmo fundo, border radius e sombra.
class ListagemSidebarFiltros extends StatelessWidget {
  const ListagemSidebarFiltros({
    super.key,
    required this.items,
    this.largura = 180,
  });

  final List<ListagemFiltroItem> items;
  final double largura;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      child: Material(
        color: AppColors.listagemItemBackground,
        borderRadius: BorderRadius.circular(AppSpacing.listagemCardBorderRadius),
        elevation: AppSpacing.listagemContentCardElevation,
        shadowColor: AppColors.cardShadowColor,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 4),
                _buildItem(items[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(ListagemFiltroItem item) {
    final bgColor = item.isSelected
        ? AppColors.contentBackground
        : Colors.transparent;
    final textColor = item.isSelected
        ? AppColors.textPrimary
        : AppColors.textSecondary;
    final iconColor = item.isSelected
        ? AppColors.primary
        : AppColors.textSecondary;
    final fontWeight = item.isSelected ? FontWeight.w600 : FontWeight.normal;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppSpacing.listagemCodeBadgeBorderRadius),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.listagemCodeBadgeBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 10,
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: fontWeight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
