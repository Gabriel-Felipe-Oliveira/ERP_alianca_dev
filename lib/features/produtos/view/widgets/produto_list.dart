import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/listagem_letter_group.dart';
import 'package:erp_alianca_dev/shared/widgets/listagem_letter_section_header.dart';
import 'package:erp_alianca_dev/shared/widgets/listagem_list_card.dart';

/// Largura do ícone e da coluna ID na listagem de produtos.
const double kProdutoListIconWidth = 40;
const double kProdutoListIdColumnWidth = 70;

String formatarPrecoProdutoList(double preco) {
  return preco.toStringAsFixed(2).replaceAll('.', ',');
}

/// Lista de produtos agrupada por letra do nome.
class ProdutoList extends StatelessWidget {
  const ProdutoList({
    super.key,
    required this.produtos,
    required this.onTap,
    this.scrollController,
    this.footer,
  });

  final List<ProdutoModel> produtos;
  final void Function(ProdutoModel produto) onTap;
  final ScrollController? scrollController;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    if (produtos.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = ListagemLetterGroup.build<ProdutoModel>(
      items: produtos,
      label: (p) => p.nome,
    );

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length + (footer != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (footer != null && index == items.length) return footer!;
        final entry = items[index];
        if (entry.isHeader) {
          return ListagemLetterSectionHeader(letter: entry.letter!);
        }
        final produto = entry.item!;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ProdutoListItem(
            produto: produto,
            onTap: () => onTap(produto),
          ),
        );
      },
    );
  }
}

class ProdutoListItem extends StatelessWidget {
  const ProdutoListItem({
    super.key,
    required this.produto,
    this.onTap,
  });

  final ProdutoModel produto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final codigo = produto.idProduto != null
        ? '#${produto.idProduto!.toString().padLeft(5, '0')}'
        : '—';
    return ListagemListItem(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: kProdutoListIconWidth,
            child: Icon(
              Icons.inventory_2_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(
            width: kProdutoListIdColumnWidth,
            child: Text(
              codigo,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              produto.nome,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'R\$ ${formatarPrecoProdutoList(produto.preco)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
