import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Período selecionado no filtro da listagem.
enum ListagemPeriodo {
  ultimoMes,
  anoTodo,
}

/// Dois botões no topo da listagem: "Último mês" e "Ano todo".
/// O selecionado recebe marcador de cor (barra lateral + fundo).
class ListagemPeriodoFilter extends StatefulWidget {
  const ListagemPeriodoFilter({
    super.key,
    this.periodoInicial = ListagemPeriodo.ultimoMes,
    this.onPeriodoChanged,
    this.padding,
  });

  final ListagemPeriodo periodoInicial;
  final ValueChanged<ListagemPeriodo>? onPeriodoChanged;

  /// Padding ao redor dos botões. Se null, usa padding padrão da tela.
  final EdgeInsetsGeometry? padding;

  @override
  State<ListagemPeriodoFilter> createState() => _ListagemPeriodoFilterState();
}

class _ListagemPeriodoFilterState extends State<ListagemPeriodoFilter> {
  late ListagemPeriodo _periodo;

  @override
  void initState() {
    super.initState();
    _periodo = widget.periodoInicial;
  }

  @override
  void didUpdateWidget(ListagemPeriodoFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.periodoInicial != oldWidget.periodoInicial) {
      _periodo = widget.periodoInicial;
    }
  }

  void _select(ListagemPeriodo value) {
    if (_periodo == value) return;
    setState(() => _periodo = value);
    widget.onPeriodoChanged?.call(_periodo);
  }

  @override
  Widget build(BuildContext context) {
    final effectivePadding = widget.padding ??
        const EdgeInsets.fromLTRB(
          AppSpacing.listagemScreenPadding,
          0,
          AppSpacing.listagemScreenPadding,
          AppSpacing.md,
        );
    return Padding(
      padding: effectivePadding,
      child: Row(
        children: [
          Expanded(
            child: _PeriodoButton(
              label: 'Último mês',
              isSelected: _periodo == ListagemPeriodo.ultimoMes,
              onTap: () => _select(ListagemPeriodo.ultimoMes),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _PeriodoButton(
              label: 'Ano todo',
              isSelected: _periodo == ListagemPeriodo.anoTodo,
              onTap: () => _select(ListagemPeriodo.anoTodo),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodoButton extends StatefulWidget {
  const _PeriodoButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_PeriodoButton> createState() => _PeriodoButtonState();
}

class _PeriodoButtonState extends State<_PeriodoButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isSelected
        ? AppColors.contentBackground
        : AppColors.listagemItemBackground;
    final hoverColor = widget.isSelected
        ? AppColors.input
        : AppColors.actionBarHover;
    final color = _hovering ? hoverColor : baseColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppSpacing.listagemCodeBadgeBorderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: AppColors.border, width: 1),
              borderRadius: BorderRadius.circular(AppSpacing.listagemCodeBadgeBorderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isSelected)
                  Icon(Icons.folder, size: 18, color: AppColors.primary),
                if (widget.isSelected) const SizedBox(width: AppSpacing.xs),
                Text(
                  widget.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: widget.isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
