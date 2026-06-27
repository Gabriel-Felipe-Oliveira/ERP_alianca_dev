import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Barra de pesquisa centralizada para telas de listagem.
/// Leve e integrada ao layout (fundo mais escuro que os cards, não parece card).
/// [onFocus]: chamado quando o campo ganha foco (ex.: carregar resultados sem filtro).
class ListagemSearchBar extends StatefulWidget {
  const ListagemSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFocus,
    this.hintText = 'Buscar...',
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFocus;
  final String hintText;

  @override
  State<ListagemSearchBar> createState() => _ListagemSearchBarState();
}

class _ListagemSearchBarState extends State<ListagemSearchBar> {
  bool _hovering = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && widget.onFocus != null) {
      widget.onFocus!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.listagemScreenPadding,
        AppSpacing.lg,
        AppSpacing.listagemScreenPadding,
        AppSpacing.sm,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.listagemSearchBarHover : AppColors.listagemSearchBarBackground,
            borderRadius: BorderRadius.circular(AppSpacing.listagemSearchBarBorderRadius),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.listagemSearchBarBorderRadius),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
