import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar_menu_item.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';

class SidebarWidget extends StatefulWidget {
  /// Largura do Figma: 256px
  static const double sidebarWidth = 256;

  const SidebarWidget({super.key});

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  /// Seção que está colapsando (para animação sequencial: fecha primeiro, abre depois).
  String? _collapsingSection;

  /// Para detectar double-tap: última seção clicada e quando.
  String? _lastSectionTapRoute;
  DateTime? _lastSectionTapTime;

  static const _doubleTapMs = 400;

  /// Path completo da rota atual (ex: /pedidos/criar).
  /// Usar [uri.path] em vez de [matchedLocation] para que subrotas dentro do
  /// ShellRoute marquem corretamente o subitem ativo (ex: Criar, Editar).
  static String _currentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  @override
  Widget build(BuildContext context) {
    final String currentLocation = _currentPath(context);

    return Container(
      width: SidebarWidget.sidebarWidth,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Logo
          _buildHeader(),

          const SizedBox(height: 8),
          Divider(height: 2, color: AppColors.sidebarDivider, thickness: 2),
          const SizedBox(height: 8),

          // Menu items (Figma Navigation gap: 8px)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Home
                SidebarMenuItem(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  route: AppRoutes.home,
                  isSelected: currentLocation == AppRoutes.home,
                  onTap: () => context.go(AppRoutes.home),
                ),

                // Clientes
                SidebarMenuItemExpandable(
                  icon: Icons.people_outline,
                  title: 'Clientes',
                  baseRoute: AppRoutes.clientes,
                  currentLocation: currentLocation,
                  collapsingSection: _collapsingSection,
                  onTapBase: () => _onSectionTap(
                    context,
                    currentLocation,
                    AppRoutes.clientes,
                  ),
                  onLongPressBase: () => context.go(AppRoutes.home),
                  subItems: [
                    SidebarSubItem(
                      title: 'Listagem',
                      route: AppRoutes.clientes,
                      isSelected: currentLocation == AppRoutes.clientes,
                      onTap: () => context.go(AppRoutes.clientes),
                    ),
                    SidebarSubItem(
                      title: 'Criar',
                      route: AppRoutes.clientesCriar,
                      isSelected:
                          currentLocation == AppRoutes.clientesCriar,
                      onTap: () => context.go(AppRoutes.clientesCriar),
                    ),
                  ],
                ),

                // Produtos
                SidebarMenuItemExpandable(
                  icon: Icons.inventory_2_outlined,
                  title: 'Produtos',
                  baseRoute: AppRoutes.produtos,
                  currentLocation: currentLocation,
                  collapsingSection: _collapsingSection,
                  onTapBase: () => _onSectionTap(
                    context,
                    currentLocation,
                    AppRoutes.produtos,
                  ),
                  onLongPressBase: () => context.go(AppRoutes.home),
                  subItems: [
                    SidebarSubItem(
                      title: 'Listagem',
                      route: AppRoutes.produtos,
                      isSelected: currentLocation == AppRoutes.produtos,
                      onTap: () => context.go(AppRoutes.produtos),
                    ),
                    SidebarSubItem(
                      title: 'Criar',
                      route: AppRoutes.produtosCriar,
                      isSelected:
                          currentLocation == AppRoutes.produtosCriar,
                      onTap: () => context.go(AppRoutes.produtosCriar),
                    ),
                  ],
                ),

                // Pedidos
                SidebarMenuItemExpandable(
                  icon: Icons.receipt_long_outlined,
                  title: 'Pedidos',
                  baseRoute: AppRoutes.pedidos,
                  currentLocation: currentLocation,
                  collapsingSection: _collapsingSection,
                  onTapBase: () => _onSectionTap(
                    context,
                    currentLocation,
                    AppRoutes.pedidos,
                  ),
                  onLongPressBase: () => context.go(AppRoutes.home),
                  subItems: [
                    SidebarSubItem(
                      title: 'Listagem',
                      route: AppRoutes.pedidos,
                      isSelected: currentLocation == AppRoutes.pedidos,
                      onTap: () => context.go(AppRoutes.pedidos),
                    ),
                    SidebarSubItem(
                      title: 'Criar',
                      route: AppRoutes.pedidosCriar,
                      isSelected:
                          currentLocation == AppRoutes.pedidosCriar,
                      onTap: () => context.go(AppRoutes.pedidosCriar),
                    ),
                  ],
                ),

                // Romaneio
                SidebarMenuItemExpandable(
                  icon: Icons.local_shipping_outlined,
                  title: 'Romaneio',
                  baseRoute: AppRoutes.romaneio,
                  currentLocation: currentLocation,
                  collapsingSection: _collapsingSection,
                  onTapBase: () => _onSectionTap(
                    context,
                    currentLocation,
                    AppRoutes.romaneio,
                  ),
                  onLongPressBase: () => context.go(AppRoutes.home),
                  subItems: [
                    SidebarSubItem(
                      title: 'Listagem',
                      route: AppRoutes.romaneio,
                      isSelected: currentLocation == AppRoutes.romaneio,
                      onTap: () => context.go(AppRoutes.romaneio),
                    ),
                    SidebarSubItem(
                      title: 'Criar',
                      route: AppRoutes.romaneioCriar,
                      isSelected:
                          currentLocation == AppRoutes.romaneioCriar,
                      onTap: () => context.go(AppRoutes.romaneioCriar),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _buildFooter(),
        ],
      ),
    );
  }

  /// Ao clicar na seção: abre ou troca. Para fechar: double-tap ou long-press.
  void _onSectionTap(
    BuildContext context,
    String currentLocation,
    String targetRoute,
  ) {
    // Mesma seção aberta: double-tap fecha, single-tap não faz nada
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

    // Outra seção aberta: colapsa primeiro, depois navega
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

    // Nenhuma seção aberta: navega direto
    context.go(targetRoute);
  }

  String? _getOpenSection(String currentLocation) {
    if (currentLocation.startsWith(AppRoutes.clientes)) return AppRoutes.clientes;
    if (currentLocation.startsWith(AppRoutes.produtos)) return AppRoutes.produtos;
    if (currentLocation.startsWith(AppRoutes.pedidos)) return AppRoutes.pedidos;
    if (currentLocation.startsWith(AppRoutes.romaneio)) return AppRoutes.romaneio;
    return null;
  }

  Widget _buildHeader() {
    return Text(
      'Vendas Base',
      style: AppTextStyles.heading2.copyWith(
        color: AppColors.sidebarTextActive,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'v1.0.0',
      style: AppTextStyles.caption.copyWith(
        color: AppColors.sidebarTextMuted,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
