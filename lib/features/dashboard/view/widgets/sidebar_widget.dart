import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/core/constants/app_constants.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar_menu_item.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_interactive.dart';
import 'package:erp_alianca_dev/shared/widgets/app_logo.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tooltip.dart';
import 'package:erp_alianca_dev/shared/widgets/app_theme_mode_toggle.dart';
import 'package:erp_alianca_dev/shared/viewmodels/theme_palette_provider.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';

class SidebarWidget extends StatefulWidget {
  static const double sidebarWidth = SidebarConstants.sidebarExpandedWidth;

  const SidebarWidget({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapsed,
  });

  final bool isCollapsed;
  final VoidCallback onToggleCollapsed;

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
    context.watch<ThemePaletteProvider>();
    final auth = context.watch<AuthService>();
    final String currentLocation = _currentPath(context);
    final targetWidth = widget.isCollapsed
        ? SidebarConstants.sidebarCollapsedWidth
        : SidebarConstants.sidebarExpandedWidth;

    return AnimatedContainer(
      duration: SidebarConstants.sidebarCollapseDuration,
      curve: SidebarConstants.expandAnimationCurve,
      width: targetWidth,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        border: AppColors.isLightTheme
            ? Border(right: BorderSide(color: AppColors.border, width: 1))
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactLayout = constraints.maxWidth <
              SidebarConstants.compactLayoutBreakpoint;
          final horizontalPadding = compactLayout ? 12.0 : 24.0;

          return Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(compactLayout: compactLayout),

                const SidebarSubtleDivider(),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      SidebarMenuItem(
                        icon: Icons.home_outlined,
                        title: 'Home',
                        route: AppRoutes.home,
                        isSelected: currentLocation == AppRoutes.home,
                        isCollapsed: compactLayout,
                        onTap: () => context.go(AppRoutes.home),
                      ),

                      SidebarMenuItemExpandable(
                        icon: Icons.people_outline,
                        title: 'Clientes',
                        baseRoute: AppRoutes.clientes,
                        currentLocation: currentLocation,
                        collapsingSection: _collapsingSection,
                  isCollapsed: compactLayout,
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
                      title: 'CNPJ',
                      route: AppRoutes.clientesConsultaCnpj,
                      isSelected:
                          currentLocation == AppRoutes.clientesConsultaCnpj,
                      onTap: () => context.go(AppRoutes.clientesConsultaCnpj),
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
                  isCollapsed: compactLayout,
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
                  isCollapsed: compactLayout,
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
                  isCollapsed: compactLayout,
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

                if (auth.podeVerDashboardComercial)
                  SidebarMenuItem(
                    icon: Icons.insights_outlined,
                    title: 'Dashboard',
                    route: AppRoutes.dashboardComercial,
                    isSelected:
                        currentLocation == AppRoutes.dashboardComercial,
                    isCollapsed: compactLayout,
                    onTap: () => context.go(AppRoutes.dashboardComercial),
                  ),
              ],
            ),
          ),

          _buildFooter(compactLayout: compactLayout),
        ],
      ),
    );
        },
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

  Widget _buildHeader({required bool compactLayout}) {
    if (compactLayout) {
      return Center(
        child: _SidebarToggleButton(
          isCollapsed: widget.isCollapsed,
          onPressed: widget.onToggleCollapsed,
        ),
      );
    }

    return Row(
      children: [
        const AppLogo(
          width: 28,
          height: 28,
          fallbackIcon: Icons.storefront_outlined,
          fallbackIconSize: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Vendas Base',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.sidebarTextActive,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: -0.02,
            ),
          ),
        ),
        _SidebarToggleButton(
          isCollapsed: widget.isCollapsed,
          onPressed: widget.onToggleCollapsed,
        ),
      ],
    );
  }

  Widget _buildUserAvatar(String nome, {double radius = 18}) {
    final initial =
        nome.isNotEmpty ? nome.substring(0, 1).toUpperCase() : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.sidebarDivider,
      child: Text(
        initial,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.sidebarTextActive,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.85,
        ),
      ),
    );
  }

  Widget _buildFooter({required bool compactLayout}) {
    final auth = context.watch<AuthService>();
    final usuario = auth.usuario;

    if (compactLayout) {
      return Column(
        children: [
          const SidebarSubtleDivider(),
          if (usuario != null) ...[
            AppTooltip(
              message: '${usuario.nome}\n${usuario.email}',
              child: _buildUserAvatar(usuario.nome, radius: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const AppThemeModeToggle(compact: true),
          const SizedBox(height: AppSpacing.xs),
          _SidebarLogoutButton(
            compact: true,
            onPressed: () => _logout(context, auth),
          ),
          const SidebarSubtleDivider(),
          const _SidebarVersionLabel(compact: true),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SidebarSubtleDivider(),
        if (usuario != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildUserAvatar(usuario.nome),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.sidebarTextActive,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      usuario.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.sidebarTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const AppThemeModeToggle(),
        _SidebarLogoutButton(
          onPressed: () => _logout(context, auth),
        ),
        const SidebarSubtleDivider(),
        const _SidebarVersionLabel(),
      ],
    );
  }

  Future<void> _logout(BuildContext context, AuthService auth) async {
    final router = GoRouter.of(context);
    await auth.logout();
    if (!context.mounted) return;
    router.go(AppRoutes.login);
  }
}

class _SidebarLogoutButton extends StatefulWidget {
  const _SidebarLogoutButton({
    required this.onPressed,
    this.compact = false,
  });

  final VoidCallback onPressed;
  final bool compact;

  @override
  State<_SidebarLogoutButton> createState() => _SidebarLogoutButtonState();
}

class _SidebarLogoutButtonState extends State<_SidebarLogoutButton> {
  bool _isHovered = false;

  Color get _contentColor =>
      _isHovered ? AppColors.error : AppColors.sidebarTextMuted;

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return SidebarCollapsedIconTile(
        icon: Icons.logout_outlined,
        label: 'Sair',
        isSelected: false,
        iconColor: _contentColor,
        onTap: widget.onPressed,
        onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
      );
    }

    return SidebarInteractiveTile(
      isSelected: false,
      isHovered: _isHovered,
      onHoverChanged: (hovered) => setState(() => _isHovered = hovered),
      onTap: widget.onPressed,
      marginBottom: 0,
      child: Row(
        children: [
          Icon(
            Icons.logout_outlined,
            color: _contentColor,
            size: SidebarLayout.iconSize,
          ),
          const SizedBox(width: 12),
          Text(
            'Sair',
            style: TextStyle(
              color: _contentColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              letterSpacing: -0.02,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarVersionLabel extends StatelessWidget {
  const _SidebarVersionLabel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Versão ${AppConstants.appVersion}',
      textAlign: compact ? TextAlign.center : TextAlign.start,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.sidebarTextMuted.withValues(alpha: 0.75),
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _SidebarToggleButton extends StatefulWidget {
  const _SidebarToggleButton({
    required this.isCollapsed,
    required this.onPressed,
  });

  final bool isCollapsed;
  final VoidCallback onPressed;

  @override
  State<_SidebarToggleButton> createState() => _SidebarToggleButtonState();
}

class _SidebarToggleButtonState extends State<_SidebarToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AppTooltip(
      message: widget.isCollapsed ? 'Expandir menu' : 'Recolher menu',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: SidebarLayout.hoverDuration,
          curve: Curves.easeOut,
          width: SidebarLayout.toggleButtonSize,
          height: SidebarLayout.toggleButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered
                ? AppColors.listagemItemHover.withValues(alpha: 0.35)
                : AppColors.sidebarDivider.withValues(alpha: 0.45),
            border: Border.all(
              color: AppColors.sidebarBorder.withValues(
                alpha: _isHovered ? 0.55 : 0.35,
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onPressed,
              splashColor: AppColors.primary.withValues(alpha: 0.12),
              child: AnimatedSwitcher(
                duration: SidebarLayout.hoverDuration,
                transitionBuilder: (child, animation) => RotationTransition(
                  turns: Tween<double>(begin: 0.85, end: 1).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Icon(
                  widget.isCollapsed
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  key: ValueKey(widget.isCollapsed),
                  size: 20,
                  color: _isHovered
                      ? AppColors.sidebarTextActive
                      : AppColors.sidebarTextMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
