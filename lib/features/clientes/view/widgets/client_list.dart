import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/clientes/view/widgets/client_tile.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/utils/listagem_letter_group.dart';
import 'package:erp_alianca_dev/shared/viewmodels/navigation_controller.dart';
import 'package:erp_alianca_dev/shared/widgets/listagem_letter_section_header.dart';

/// Lista de clientes com scroll independente: ordenada por nome e agrupada por letra.
/// Cada grupo tem um header (letra + divisor). [scrollController] para o Scrollbar.
class ClientList extends StatelessWidget {
  const ClientList({
    super.key,
    required this.clientes,
    this.scrollController,
    this.footer,
  });

  final List<ClienteModel> clientes;
  final ScrollController? scrollController;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    if (clientes.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = ListagemLetterGroup.build<ClienteModel>(
      items: clientes,
      label: (c) => c.nome,
    );

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      itemCount: items.length + (footer != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (footer != null && index == items.length) return footer!;
        final entry = items[index];
        if (entry.isHeader) {
          return ListagemLetterSectionHeader(letter: entry.letter!);
        }
        final cliente = entry.item!;
        return ClientTile(
          cliente: cliente,
          onTap: () {
            if (cliente.id != null) {
              final path = AppRoutes.clientesDetalhesId(cliente.id!);
              context.read<NavigationController>().registrarRota(path);
              context.go(path);
            }
          },
          onNovoPedido: (c) {
            context.read<NavigationController>().registrarRota(AppRoutes.pedidosCriar);
            context.go(AppRoutes.pedidosCriar, extra: c);
          },
        );
      },
    );
  }
}
