import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Coloca o [filtro] ao lado esquerdo do [painel], sem reduzir o tamanho do painel.
/// O painel ocupa todo o espaço; o filtro fica posicionado sobre a borda esquerda.
/// O [child] (conteúdo do painel) recebe padding à esquerda para não sobrepor o filtro.
class ListagemPanelComFiltroLateral extends StatelessWidget {
  const ListagemPanelComFiltroLateral({
    super.key,
    required this.filtro,
    required this.child,
    this.margemEsquerdaFiltro,
    this.margemSuperiorFiltro,
    this.larguraReservadaFiltro = 140,
  });

  /// Widget do filtro (ex.: ListagemFilterButton "Todos (20)").
  final Widget filtro;

  /// Conteúdo do painel (lista, loading, etc.). Será envolvido em padding à esquerda.
  final Widget child;

  /// Margem à esquerda do filtro em relação à tela.
  final double? margemEsquerdaFiltro;

  /// Margem superior do filtro em relação ao topo do painel.
  final double? margemSuperiorFiltro;

  /// Largura reservada à esquerda do [child] para o filtro (evita sobreposição).
  final double larguraReservadaFiltro;

  @override
  Widget build(BuildContext context) {
    final leftFilter = margemEsquerdaFiltro ?? AppSpacing.listagemScreenPadding;
    final topFilter = margemSuperiorFiltro ?? 12.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(left: larguraReservadaFiltro),
          child: child,
        ),
        Positioned(
          left: leftFilter,
          top: topFilter,
          child: filtro,
        ),
      ],
    );
  }
}
