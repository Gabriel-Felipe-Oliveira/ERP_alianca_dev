import 'package:flutter/material.dart';

import 'package:erp_alianca_dev/features/home/model/home_nav_item.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';

/// Monta as seções do menu de navegação da Home (sem API).
abstract final class HomeNavMenu {
  static List<HomeNavSection> sectionsFor(AuthService auth) {
    final podeVerDashboard = auth.podeVerDashboardComercial;
    return [
      const HomeNavSection(
        title: 'Cliente',
        items: [
          HomeNavItem(
            title: '',
            actionLabel: 'Cadastro',
            icon: Icons.person_add_outlined,
            color: Color(0xFF2563EB),
            route: AppRoutes.clientesCriar,
          ),
          HomeNavItem(
            title: '',
            actionLabel: 'Listagem',
            icon: Icons.people_outline,
            color: Color(0xFF3B82F6),
            route: AppRoutes.clientes,
          ),
        ],
      ),
      const HomeNavSection(
        title: 'Produto',
        items: [
          HomeNavItem(
            title: '',
            actionLabel: 'Cadastro',
            icon: Icons.add_box_outlined,
            color: Color(0xFF059669),
            route: AppRoutes.produtosCriar,
          ),
          HomeNavItem(
            title: '',
            actionLabel: 'Listagem',
            icon: Icons.inventory_2_outlined,
            color: Color(0xFF10B981),
            route: AppRoutes.produtos,
          ),
        ],
      ),
      const HomeNavSection(
        title: 'Operação',
        items: [
          HomeNavItem(
            title: '',
            actionLabel: 'Criar pedido',
            icon: Icons.add_shopping_cart_outlined,
            color: Color(0xFFD97706),
            route: AppRoutes.pedidosCriar,
          ),
          HomeNavItem(
            title: '',
            actionLabel: 'Criar romaneio',
            icon: Icons.local_shipping_outlined,
            color: Color(0xFF7C3AED),
            route: AppRoutes.romaneioCriar,
          ),
        ],
      ),
      if (podeVerDashboard)
        const HomeNavSection(
          title: 'Dashboard',
          items: [
            HomeNavItem(
              title: '',
              actionLabel: 'Comercial',
              icon: Icons.insights_outlined,
              color: Color(0xFF0D9488),
              route: AppRoutes.dashboardComercial,
            ),
          ],
        ),
    ];
  }
}
