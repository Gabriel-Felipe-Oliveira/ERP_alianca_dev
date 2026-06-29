import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar_menu_item.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';

/// Lista de navegação da sidebar. Encapsula o estado de expansão/colapso das
/// seções e a lógica de duplo-toque para recolher.
class SidebarNavigation extends StatefulWidget {
  const SidebarNavigation({super.key, required this.compactLayout});

  final bool compactLayout;

  @override
  State<SidebarNavigation> createState() => _SidebarNavigationState();
}

class _SidebarNavigationState extends State<SidebarNavigation> {
  /// Seção que está colapsando (para animação sequencial: fecha, depois abre).
  String? _collapsingSection;

  /// Para detectar double-tap: última seção clicada e quando.
  String? _lastSectionTapRoute;
  DateTime? _lastSectionTapTime;

  static const _doubleTapMs = 400;

  /// Path completo da rota atual (ex: /pedidos/criar). Usa [uri.path] para que
  /// subrotas dentro do ShellRoute marquem o subitem ativo corretamente.
  String _currentPath() => GoRouterState.of(context).uri.path;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final currentLocation = _currentPath();
    final compact = widget.compactLayout;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SidebarMenuItem(
          icon: Icons.home_outlined,
          title: 'Home',
          route: AppRoutes.home,
          isSelected: currentLocation == AppRoutes.home,
          isCollapsed: compact,
          onTap: () => context.go(AppRoutes.home),
        ),
        _secao(
          icon: Icons.people_outline,
          title: 'Clientes',
          baseRoute: AppRoutes.clientes,
          currentLocation: currentLocation,
          compact: compact,
          subItems: [
            _sub('Listagem', AppRoutes.clientes, currentLocation),
            _sub('CNPJ', AppRoutes.clientesConsultaCnpj, currentLocation),
            _sub('Criar', AppRoutes.clientesCriar, currentLocation),
          ],
        ),
        _secao(
          icon: Icons.inventory_2_outlined,
          title: 'Produtos',
          baseRoute: AppRoutes.produtos,
          currentLocation: currentLocation,
          compact: compact,
          subItems: [
            _sub('Listagem', AppRoutes.produtos, currentLocation),
            _sub('Criar', AppRoutes.produtosCriar, currentLocation),
          ],
        ),
        _secao(
          icon: Icons.receipt_long_outlined,
          title: 'Pedidos',
          baseRoute: AppRoutes.pedidos,
          currentLocation: currentLocation,
          compact: compact,
          subItems: [
            _sub('Listagem', AppRoutes.pedidos, currentLocation),
            _sub('Criar', AppRoutes.pedidosCriar, currentLocation),
          ],
        ),
        _secao(
          icon: Icons.local_shipping_outlined,
          title: 'Romaneio',
          baseRoute: AppRoutes.romaneio,
          currentLocation: currentLocation,
          compact: compact,
          subItems: [
            _sub('Listagem', AppRoutes.romaneio, currentLocation),
            _sub('Criar', AppRoutes.romaneioCriar, currentLocation),
          ],
        ),
        if (auth.podeVerDashboardComercial)
          SidebarMenuItem(
            icon: Icons.insights_outlined,
            title: 'Dashboard',
            route: AppRoutes.dashboardComercial,
            isSelected: currentLocation == AppRoutes.dashboardComercial,
            isCollapsed: compact,
            onTap: () => context.go(AppRoutes.dashboardComercial),
          ),
      ],
    );
  }

  Widget _secao({
    required IconData icon,
    required String title,
    required String baseRoute,
    required String currentLocation,
    required bool compact,
    required List<SidebarSubItem> subItems,
  }) {
    return SidebarMenuItemExpandable(
      icon: icon,
      title: title,
      baseRoute: baseRoute,
      currentLocation: currentLocation,
      collapsingSection: _collapsingSection,
      isCollapsed: compact,
      onTapBase: () => _onSectionTap(context, currentLocation, baseRoute),
      onLongPressBase: () => context.go(AppRoutes.home),
      subItems: subItems,
    );
  }

  SidebarSubItem _sub(String title, String route, String currentLocation) {
    return SidebarSubItem(
      title: title,
      route: route,
      isSelected: currentLocation == route,
      onTap: () => context.go(route),
    );
  }

  /// Ao clicar na seção: abre ou troca. Para fechar: double-tap ou long-press.
  void _onSectionTap(
    BuildContext context,
    String currentLocation,
    String targetRoute,
  ) {
    if (currentLocation.startsWith(targetRoute)) {
      final now = DateTime.now();
      final isDoubleTap = _lastSectionTapRoute == targetRoute &&
          _lastSectionTapTime != null &&
          now.difference(_lastSectionTapTime!).inMilliseconds < _doubleTapMs;

      if (isDoubleTap) {
        _lastSectionTapTime = null;
        _lastSectionTapRoute = null;
        context.go(AppRoutes.home);
      } else {
        _lastSectionTapTime = now;
        _lastSectionTapRoute = targetRoute;
      }
      return;
    }

    _lastSectionTapTime = null;
    _lastSectionTapRoute = null;

    final openSection = _getOpenSection(currentLocation);
    if (openSection != null) {
      setState(() => _collapsingSection = openSection);
      Future.delayed(SidebarConstants.expandAnimationDuration, () {
        if (!context.mounted) return;
        context.go(targetRoute);
        setState(() => _collapsingSection = null);
      });
      return;
    }

    context.go(targetRoute);
  }

  String? _getOpenSection(String currentLocation) {
    if (currentLocation.startsWith(AppRoutes.clientes)) {
      return AppRoutes.clientes;
    }
    if (currentLocation.startsWith(AppRoutes.produtos)) {
      return AppRoutes.produtos;
    }
    if (currentLocation.startsWith(AppRoutes.pedidos)) {
      return AppRoutes.pedidos;
    }
    if (currentLocation.startsWith(AppRoutes.romaneio)) {
      return AppRoutes.romaneio;
    }
    return null;
  }
}
