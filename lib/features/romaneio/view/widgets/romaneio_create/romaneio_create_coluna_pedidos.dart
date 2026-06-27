import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/pedido_selecionado_item.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/pedido_selectable_card.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

class RomaneioCreateColunaPedidos extends StatelessWidget {
  const RomaneioCreateColunaPedidos({
    super.key,
    required this.vm,
    required this.useExpanded,
  });

  final RomaneioCriarViewModel vm;
  final bool useExpanded;

  @override
  Widget build(BuildContext context) {
    const listDisponiveisMaxHeight = 280.0;
    const listSelecionadosMaxHeight = 140.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(AppSpacing.formContainerBorderRadius),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: useExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Text(
            'Pedidos Confirmados',
            style: AppTextStyles.sectionTitleSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            onChanged: vm.setSearchQuery,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar pedido...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              isDense: true,
              filled: true,
              fillColor: AppColors.sidebarItemBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (useExpanded)
            Expanded(child: RomaneioCreatePedidosDisponiveisList(vm: vm))
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: listDisponiveisMaxHeight),
              child: RomaneioCreatePedidosDisponiveisList(vm: vm),
            ),
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: AppColors.cardBorder, thickness: 1),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pedidos Selecionados',
            style: AppTextStyles.sectionTitleSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: listSelecionadosMaxHeight,
            child: RomaneioCreatePedidosSelecionadosList(vm: vm),
          ),
        ],
      ),
    );
  }
}

class RomaneioCreatePedidosDisponiveisList extends StatelessWidget {
  const RomaneioCreatePedidosDisponiveisList({super.key, required this.vm});

  final RomaneioCriarViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoadingPedidos) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }
    final list = vm.pedidosFiltrados;
    if (list.isEmpty) {
      return RomaneioCreateEmptyPedidosState(
        hasSearch: vm.searchQuery.trim().isNotEmpty,
      );
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final pedido = list[index];
        return PedidoSelectableCard(
          pedido: pedido,
          isSelected: vm.estaSelecionado(pedido),
          onTap: () => vm.togglePedido(pedido),
          nomeCliente: vm.nomeCliente(pedido.idCliente),
        );
      },
    );
  }
}

class RomaneioCreatePedidosSelecionadosList extends StatelessWidget {
  const RomaneioCreatePedidosSelecionadosList({super.key, required this.vm});

  final RomaneioCriarViewModel vm;

  @override
  Widget build(BuildContext context) {
    final list = vm.pedidosSelecionados;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: list.isEmpty
          ? Center(
              child: Text(
                'Nenhum pedido selecionado',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth * 0.30).clamp(85.0, 130.0);
                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: list.map((pedido) {
                      return SizedBox(
                        width: itemWidth,
                        child: PedidoSelecionadoItem(
                          pedido: pedido,
                          onTap: () => vm.togglePedido(pedido),
                          nomeCliente: vm.nomeCliente(pedido.idCliente),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}

class RomaneioCreateEmptyPedidosState extends StatelessWidget {
  const RomaneioCreateEmptyPedidosState({super.key, required this.hasSearch});

  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.inbox_outlined,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasSearch
                  ? 'Nenhum pedido encontrado para essa busca.'
                  : 'Nenhum pedido com status "Pronto para Entrega" no momento.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
