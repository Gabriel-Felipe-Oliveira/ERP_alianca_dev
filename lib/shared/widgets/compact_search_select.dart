import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_shimmer.dart';

/// Barra de pesquisa compacta (~metade da listagem) que abre resultados logo abaixo.
/// O usuário digita, dispara a busca (submit) e clica em um item para escolher.
class CompactSearchSelect<T> extends StatefulWidget {
  const CompactSearchSelect({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSearch,
    this.onChanged,
    this.onFocus,
    required this.isLoading,
    required this.items,
    required this.itemBuilder,
    required this.onItemSelected,
    this.errorMessage,
    this.maxListHeight = 220,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSearch;
  /// Chamado quando o texto muda (ex.: para debounce e buscar ao parar de digitar).
  final ValueChanged<String>? onChanged;
  /// Chamado quando o campo ganha foco (ex.: carregar lista ao clicar).
  final VoidCallback? onFocus;
  final bool isLoading;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final ValueChanged<T> onItemSelected;
  final String? errorMessage;
  final double maxListHeight;

  @override
  State<CompactSearchSelect<T>> createState() => _CompactSearchSelectState<T>();
}

class _CompactSearchSelectState<T> extends State<CompactSearchSelect<T>> {
  bool _hovering = false;

  static const double _compactBorderRadius = 10;
  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final showPanel = widget.isLoading ||
        widget.items.isNotEmpty ||
        (widget.errorMessage != null && widget.errorMessage!.isNotEmpty);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: _hovering
                  ? AppColors.listagemSearchBarHover
                  : AppColors.listagemSearchBarBackground,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(_compactBorderRadius),
                bottom: Radius.circular(showPanel ? 0 : _compactBorderRadius),
              ),
            ),
            child: TextField(
              controller: widget.controller,
              onTap: widget.onFocus != null
                  ? () {
                      widget.onFocus!();
                    }
                  : null,
              onChanged: widget.onChanged,
              onSubmitted: (_) => widget.onSearch(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: _iconSize,
                ),
                filled: true,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(_compactBorderRadius),
                    bottom: Radius.circular(showPanel ? 0 : _compactBorderRadius),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        if (showPanel) _buildPanel(),
      ],
    );
  }

  Widget _buildPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.listagemSearchBarBackground,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(_compactBorderRadius),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      constraints: BoxConstraints(maxHeight: widget.maxListHeight),
      child: widget.isLoading
          ? _buildLoading()
          : (widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
              ? _buildError()
              : _buildList(),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, _) => const AppShimmer(
          width: double.infinity,
          height: 40,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        widget.errorMessage!,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildList() {
    final items = widget.items;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          'Nenhum resultado.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      physics: const ClampingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        color: AppColors.border,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => widget.onItemSelected(item),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 10,
            ),
            child: widget.itemBuilder(context, item),
          ),
        );
      },
    );
  }
}
