import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Layout base para telas de listagem: barra de pesquisa (opcional), header (opcional) e corpo em scroll.
/// Reutilizável em todas as rotas de listagem (clientes, produtos, pedidos, etc.).
class ListagemScreenLayout extends StatelessWidget {
  const ListagemScreenLayout({
    super.key,
    this.searchBar,
    this.header,
    required this.body,
    this.spacingBetweenHeaderAndBody = AppSpacing.md,
    this.maxContentWidth,
  });

  /// Barra de pesquisa centralizada (opcional).
  final Widget? searchBar;

  /// Header com código + nome da entidade (opcional).
  final Widget? header;

  /// Conteúdo principal (lista ou outro scroll). Ocupa o espaço restante.
  final Widget body;

  /// Espaço entre header e body.
  final double spacingBetweenHeaderAndBody;

  /// Largura máxima da área de conteúdo. Quando informado (ex.: listagem com sidebar), permite layout mais largo.
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final maxWidth = maxContentWidth ?? AppSpacing.listagemContentMaxWidth;
    return Scaffold(
      backgroundColor: AppColors.contentBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                ...? (searchBar != null ? [searchBar!] : null),
                ...? (header != null ? [header!] : null),
                ...? (header != null ? [SizedBox(height: spacingBetweenHeaderAndBody)] : null),
                Expanded(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
