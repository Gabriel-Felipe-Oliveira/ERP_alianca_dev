import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_alianca_dev/features/home/view/widgets/dashboard_card.dart';
import 'package:erp_alianca_dev/features/home/viewmodel/home_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';

/// Constrói a lista de cards do grid da Home.
class HomeDashboardCards {
  HomeDashboardCards._();

  static List<Widget> buildList(BuildContext context, HomeViewModel vm) {
    return [
      DashboardCard(
        title: 'Clientes',
        icon: Icons.people_outline,
        total: vm.totalClientes.toString(),
        color: _CardColors.clientes,
        onTap: () => context.go(AppRoutes.clientes),
      ),
      DashboardCard(
        title: 'Produtos',
        icon: Icons.inventory_2_outlined,
        total: vm.totalProdutos.toString(),
        color: _CardColors.produtos,
        onTap: () => context.go(AppRoutes.produtos),
      ),
      DashboardCard(
        title: 'Pedidos',
        icon: Icons.shopping_cart_outlined,
        total: vm.totalPedidos.toString(),
        color: _CardColors.pedidos,
        onTap: () => context.go(AppRoutes.pedidos),
      ),
      DashboardCard(
        title: 'Cliente com mais pedidos',
        icon: Icons.emoji_events_outlined,
        total: vm.clienteComMaisPedidos,
        color: _CardColors.clienteDestaque,
        onTap: () => context.go(AppRoutes.clientes),
      ),
      DashboardCard(
        title: 'Produto mais vendido',
        icon: Icons.trending_up,
        total: vm.produtoMaisVendido,
        color: _CardColors.produtoDestaque,
        onTap: () => context.go(AppRoutes.produtos),
      ),
      DashboardCard(
        title: 'Maior pedido',
        icon: Icons.receipt_long_outlined,
        total: vm.maiorPedido,
        color: _CardColors.maiorPedido,
        onTap: () => context.go(AppRoutes.pedidos),
      ),
    ];
  }
}

class _CardColors {
  _CardColors._();

  static const clientes = Color(0xFF2563EB);
  static const produtos = Color(0xFF059669);
  static const pedidos = Color(0xFFD97706);
  static const clienteDestaque = Color(0xFFB45309);
  static const produtoDestaque = Color(0xFF0D9488);
  static const maiorPedido = Color(0xFF7C3AED);
}
