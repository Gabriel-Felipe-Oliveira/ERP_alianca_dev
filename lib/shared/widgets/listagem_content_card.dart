import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Card container reutilizável para telas de listagem.
/// Aplica fundo, bordas arredondadas, elevação e clip padrão.
/// Recebe um header (ex.: botões de filtro) e o body (lista).
class ListagemContentCard extends StatelessWidget {
  const ListagemContentCard({
    super.key,
    this.header,
    required this.body,
    this.padding,
  });

  /// Widget exibido acima da lista (ex.: filtros).
  final Widget? header;

  /// Conteúdo principal (lista, grid, etc.). Ocupa o espaço restante.
  final Widget body;

  /// Padding externo do card. Se null, usa o padding padrão da listagem.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        const EdgeInsets.fromLTRB(
          AppSpacing.listagemScreenPadding,
          0,
          AppSpacing.listagemScreenPadding,
          AppSpacing.listagemScreenPadding,
        );

    return Padding(
      padding: effectivePadding,
      child: Material(
        color: AppColors.listagemItemBackground,
        borderRadius: BorderRadius.circular(AppSpacing.listagemCardBorderRadius),
        elevation: AppSpacing.listagemContentCardElevation,
        shadowColor: AppColors.cardShadowColor,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (header != null)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.listagemContentCardPadding,
                  right: AppSpacing.listagemContentCardPadding,
                  top: AppSpacing.listagemContentCardPadding,
                  bottom: AppSpacing.md,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: header!,
                ),
              ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
