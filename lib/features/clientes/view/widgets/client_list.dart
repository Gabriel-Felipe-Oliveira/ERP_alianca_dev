import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/clientes/view/widgets/client_tile.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/viewmodels/navigation_controller.dart';

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

  /// Ordena por nome e agrupa por primeira letra. Retorna lista plana: header ou cliente.
  static List<_ListItem> _buildGroupedItems(List<ClienteModel> list) {
    if (list.isEmpty) return [];
    final sorted = List<ClienteModel>.from(list)
      ..sort((a, b) => a.nome.trim().toLowerCase().compareTo(b.nome.trim().toLowerCase()));
    final Map<String, List<ClienteModel>> groups = {};
    for (final c in sorted) {
      final name = c.nome.trim();
      final letter = name.isEmpty
          ? '?'
          : RegExp(r'[A-Za-zÀ-ú]').hasMatch(name[0])
              ? name[0].toUpperCase()
              : '#';
      groups.putIfAbsent(letter, () => []).add(c);
    }
    final letters = groups.keys.toList()..sort();
    final items = <_ListItem>[];
    for (final letter in letters) {
      items.add(_ListItem.header(letter));
      for (final c in groups[letter]!) {
        items.add(_ListItem.client(c));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (clientes.isEmpty) {
      return const SizedBox.shrink();
    }
    final items = _buildGroupedItems(clientes);
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      itemCount: items.length + (footer != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (footer != null && index == items.length) return footer!;
        final item = items[index];
        if (item.isHeader) {
          return _SectionHeader(letter: item.letter!);
        }
        return ClientTile(
          cliente: item.cliente!,
          onTap: () {
            final c = item.cliente!;
            if (c.id != null) {
              final path = AppRoutes.clientesDetalhesId(c.id!);
              context.read<NavigationController>().registrarRota(path);
              context.go(path);
            }
          },
          onNovoPedido: (cliente) {
            context.read<NavigationController>().registrarRota(AppRoutes.pedidosCriar);
            context.go(AppRoutes.pedidosCriar, extra: cliente);
          },
        );
      },
    );
  }
}

class _ListItem {
  _ListItem._({this.letter, this.cliente});
  factory _ListItem.header(String letter) => _ListItem._(letter: letter);
  factory _ListItem.client(ClienteModel c) => _ListItem._(cliente: c);
  final String? letter;
  final ClienteModel? cliente;
  bool get isHeader => letter != null;
}

/// Header de seção por letra: letra como marcador + linha sutil a partir da letra até o fim.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.section,
        bottom: AppSpacing.section,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            letter,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary.withOpacity(0.65),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.textPrimary.withOpacity(0.08),
            ),
          ),
        ],
      ),
    );
  }
}
