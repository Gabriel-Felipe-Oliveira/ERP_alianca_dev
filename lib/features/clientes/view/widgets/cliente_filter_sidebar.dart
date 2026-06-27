import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/widgets/listagem_sidebar_filtros.dart';

/// Sidebar de filtros da listagem de clientes.
/// Hoje só "Todos (n)"; preparado para futuros: Clientes com pedido, Inativos, PF, PJ.
class ClienteFilterSidebar extends StatelessWidget {
  const ClienteFilterSidebar({
    super.key,
    required this.labelTodos,
  });

  /// Label do filtro principal (ex.: "Todos (20)").
  final String labelTodos;

  @override
  Widget build(BuildContext context) {
    final items = [
      ListagemFiltroItem(
        label: labelTodos,
        isSelected: true,
        icon: Icons.people_outline,
        onTap: () {}, // estado único por enquanto
      ),
      // Futuro: Clientes com pedido, Clientes inativos, Pessoa Física, Pessoa Jurídica
    ];

    return ListagemSidebarFiltros(items: items);
  }
}
