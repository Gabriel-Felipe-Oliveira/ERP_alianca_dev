import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Container estilo card para listas nas telas de listagem.
/// Recebe o conteúdo (ex.: ListView.separated) como [child].
class ListagemListCard extends StatelessWidget {
  const ListagemListCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.listagemScreenPadding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.listagemCardBorderRadius),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );
  }
}

/// Variante visual do [ListagemListItem].
/// [searchResult] aplica elevação, gradiente sutil e borda para destacar resultados de busca.
enum ListagemListItemVariant {
  /// Estilo padrão (lista geral).
  normal,

  /// Estilo destacado: elevação + gradiente + borda (ex.: resultado de busca na lupa).
  searchResult,
}

/// Item de lista para telas de listagem: fundo igual ao fundo da tela (contentBackground), texto em branco puro.
/// Use [variant] para estilizar como resultado de busca (elevação + gradiente + borda).
class ListagemListItem extends StatefulWidget {
  const ListagemListItem({
    super.key,
    required this.child,
    this.onTap,
    this.variant = ListagemListItemVariant.normal,
    this.contentPadding,
  });

  final Widget child;

  /// Callback opcional ao tocar no item (ex.: navegar para detalhe).
  final VoidCallback? onTap;

  /// Variante visual. [searchResult] destaca o item (elevação, gradiente, borda).
  final ListagemListItemVariant variant;

  /// Padding interno do item. Se null, usa [EdgeInsets.all(AppSpacing.md)].
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<ListagemListItem> createState() => _ListagemListItemState();
}

class _ListagemListItemState extends State<ListagemListItem> {
  bool _hovering = false;

  BoxDecoration _buildDecoration() {
    final baseColor = _hovering ? AppColors.listagemItemHover : AppColors.listagemItemBackground;

    if (widget.variant == ListagemListItemVariant.searchResult) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            baseColor,
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.listagemItemBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(AppSpacing.listagemItemBorderRadius),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: widget.contentPadding ?? const EdgeInsets.all(AppSpacing.md),
          decoration: _buildDecoration(),
          child: DefaultTextStyle(
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Corpo da lista na listagem: apenas padding, sem container/card ao redor.
/// A lista já é o conteúdo; cada item tem seu próprio card.
class ListagemListBody extends StatelessWidget {
  const ListagemListBody({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        const EdgeInsets.fromLTRB(24, 16, 24, 24);
    return Padding(
      padding: effectivePadding,
      child: child,
    );
  }
}

/// Especificação de uma coluna do cabeçalho/rodapé da listagem.
/// [width]: largura fixa (ex.: 100 para ID/Romaneio). Se null, usa [flex].
/// [flex]: quando [width] é null, 0 = não expandir (última coluna de valor), >0 = Expanded(flex).
class ListagemListColumnSpec {
  const ListagemListColumnSpec({
    required this.label,
    this.width,
    this.flex = 1,
  });

  final String label;
  final double? width;
  final int flex;
}

TextStyle get _listHeaderFooterStyle => TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: AppColors.textPrimary,
  letterSpacing: 0.2,
);

/// Cabeçalho genérico da lista: uma linha com os rótulos das colunas (ex.: ID | Nome | Valor).
class ListagemListHeader extends StatelessWidget {
  const ListagemListHeader({
    super.key,
    required this.columns,
  });

  final List<ListagemListColumnSpec> columns;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          for (final spec in columns) _buildCell(spec, spec.label),
        ],
      ),
    );
  }

  Widget _buildCell(ListagemListColumnSpec spec, String text) {
    final child = Text(text, style: _listHeaderFooterStyle);
    if (spec.width != null) {
      return SizedBox(width: spec.width, child: child);
    }
    if (spec.flex > 0) {
      return Expanded(flex: spec.flex, child: child);
    }
    return child;
  }
}

/// Rodapé genérico: mesma estrutura de colunas, com [lastColumnText] na última coluna (ex.: Total: R\$ 1.234,56).
class ListagemListFooter extends StatelessWidget {
  const ListagemListFooter({
    super.key,
    required this.columns,
    required this.lastColumnText,
  });

  final List<ListagemListColumnSpec> columns;
  final String lastColumnText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++) _buildCell(columns[i], i == columns.length - 1 ? lastColumnText : ''),
        ],
      ),
    );
  }

  Widget _buildCell(ListagemListColumnSpec spec, String text) {
    final child = Text(text, style: _listHeaderFooterStyle);
    if (spec.width != null) {
      return SizedBox(width: spec.width, child: child);
    }
    if (spec.flex > 0) {
      return Expanded(flex: spec.flex, child: child);
    }
    return child;
  }
}
