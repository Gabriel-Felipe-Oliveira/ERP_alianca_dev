import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/clientes/view/cliente_criar_view.dart';
import 'package:erp_alianca_dev/features/clientes/view/cliente_detalhes_view.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/cliente_criar_viewmodel.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/cliente_editar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/cupom_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/pdf_export_service.dart';
import 'package:erp_alianca_dev/features/clientes/view/clientes_view.dart';
import 'package:erp_alianca_dev/features/dashboard/view/dashboard_shell.dart';
import 'package:erp_alianca_dev/features/home/view/home_view.dart';
import 'package:erp_alianca_dev/features/pedidos/view/pedido_criar_view.dart';
import 'package:erp_alianca_dev/features/pedidos/view/pedido_detalhes_view.dart';
import 'package:erp_alianca_dev/features/pedidos/view/pedidos_view.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_criar_viewmodel.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_detalhes_viewmodel.dart';
import 'package:erp_alianca_dev/features/produtos/view/produto_criar_view.dart';
import 'package:erp_alianca_dev/features/produtos/view/produto_detalhes_view.dart';
import 'package:erp_alianca_dev/features/produtos/view/produtos_view.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produto_criar_viewmodel.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produto_editar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import 'package:erp_alianca_dev/features/romaneio/view/romaneio_create_view.dart';
import 'package:erp_alianca_dev/features/romaneio/view/romaneio_detalhes_view.dart';
import 'package:erp_alianca_dev/features/romaneio/view/romaneio_view.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_criar_viewmodel.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_detalhe_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';
import 'package:erp_alianca_dev/shared/viewmodels/navigation_controller.dart';

/// Chave de navegação global para acessar o contexto do router.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Observer para reagir quando a tela volta a ficar visível (ex.: listagem de pedidos recarrega).
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

/// Duração da transição de fade entre telas (reduz o "flick" na troca).
const Duration _pageTransitionDuration = Duration(milliseconds: 280);

/// Cria uma página com transição de fade para suavizar a troca de tela.
CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _pageTransitionDuration,
    reverseTransitionDuration: _pageTransitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  observers: [routeObserver],
  routes: [
    // ShellRoute mantém a sidebar fixa enquanto o conteúdo muda
    ShellRoute(
      builder: (context, state, child) {
        return DashboardShell(child: child);
      },
      routes: [
        // Home
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeView(),
        ),

        // Clientes
        GoRoute(
          path: AppRoutes.clientes,
          name: 'clientes',
          builder: (context, state) => const ClientesView(),
          routes: [
            GoRoute(
              path: 'criar',
              name: 'clientes-criar',
              pageBuilder: (context, state) {
                final child = ChangeNotifierProvider<ClienteCriarViewModel>(
                  create: (ctx) => ClienteCriarViewModel(
                    ctx.read<ClienteService>(),
                    ctx.read<EmpresaService>(),
                  ),
                  child: const ClienteCriarView(),
                );
                return _fadePage(state: state, child: child);
              },
            ),
            GoRoute(
              path: 'detalhes/:id',
              name: 'clientes-detalhes',
              pageBuilder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null) {
                  return NoTransitionPage(child: const SizedBox.shrink());
                }
                final child = ChangeNotifierProvider<ClienteEditarViewModel>(
                  create: (ctx) => ClienteEditarViewModel(
                    id,
                    ctx.read<ClienteService>(),
                    ctx.read<EmpresaService>(),
                  ),
                  child: const ClienteDetalhesView(),
                );
                return _fadePage(state: state, child: child);
              },
            ),
          ],
        ),

        // Produtos
        GoRoute(
          path: AppRoutes.produtos,
          name: 'produtos',
          builder: (context, state) => const ProdutosView(),
          routes: [
            GoRoute(
              path: 'criar',
              name: 'produtos-criar',
              pageBuilder: (context, state) {
                final child = ChangeNotifierProvider<ProdutoCriarViewModel>(
                  create: (ctx) => ProdutoCriarViewModel(
                    ctx.read<ProdutoService>(),
                    ctx.read<EmpresaService>(),
                  ),
                  child: const ProdutoCriarView(),
                );
                return _fadePage(state: state, child: child);
              },
            ),
            GoRoute(
              path: 'detalhes/:id',
              name: 'produtos-detalhes',
              pageBuilder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null) {
                  return NoTransitionPage(child: const SizedBox.shrink());
                }
                final child = ChangeNotifierProvider<ProdutoEditarViewModel>(
                  create: (ctx) => ProdutoEditarViewModel(
                    id,
                    ctx.read<ProdutoService>(),
                    ctx.read<EmpresaService>(),
                  ),
                  child: const ProdutoDetalhesView(),
                );
                return _fadePage(state: state, child: child);
              },
            ),
          ],
        ),

        // Pedidos
        GoRoute(
          path: AppRoutes.pedidos,
          name: 'pedidos',
          builder: (context, state) => const PedidosView(),
          routes: [
            GoRoute(
              path: 'criar',
              name: 'pedidos-criar',
              pageBuilder: (context, state) {
                final clientePreSelecionado = state.extra is ClienteModel
                    ? state.extra as ClienteModel
                    : null;
                final child = ChangeNotifierProvider<PedidoCriarViewModel>(
                  create: (ctx) => PedidoCriarViewModel(
                    ctx.read<ClienteService>(),
                    ctx.read<ProdutoService>(),
                    ctx.read<PedidoService>(),
                    ctx.read<EmpresaService>(),
                  ),
                  child: _PedidoCriarInicializador(
                    cliente: clientePreSelecionado,
                    child: const PedidoCriarView(),
                  ),
                );
                return _fadePage(state: state, child: child);
              },
            ),
            GoRoute(
              path: 'detalhes/:id',
              name: 'pedidos-detalhes',
              pageBuilder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null) {
                  return NoTransitionPage(child: const SizedBox.shrink());
                }
                final child = ChangeNotifierProvider<PedidoDetalhesViewModel>(
                  create: (ctx) => PedidoDetalhesViewModel(
                    ctx.read<PedidoService>(),
                    ctx.read<ProdutoService>(),
                    ctx.read<EmpresaService>(),
                    ctx.read<CupomService>(),
                    ctx.read<ClienteService>(),
                    ctx.read<PdfExportService>(),
                    idPedido: id,
                  ),
                  child: const PedidoDetalhesView(),
                );
                return _fadePage(state: state, child: child);
              },
            ),
          ],
        ),

        // Romaneio
        GoRoute(
          path: AppRoutes.romaneio,
          name: 'romaneio',
          builder: (context, state) => const RomaneioView(),
          routes: [
            GoRoute(
              path: 'criar',
              name: 'romaneio-criar',
              pageBuilder: (context, state) {
                final child = ChangeNotifierProvider<RomaneioCriarViewModel>(
                  create: (ctx) => RomaneioCriarViewModel(
                    ctx.read<PedidoService>(),
                    ctx.read<RomaneioService>(),
                    ctx.read<EmpresaService>(),
                    ctx.read<ClienteService>(),
                  ),
                  child: const RomaneioCreateView(),
                );
                return _fadePage(state: state, child: child);
              },
            ),
            GoRoute(
              path: 'detalhes/:id',
              name: 'romaneio-detalhes',
              pageBuilder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null || id <= 0) {
                  return _fadePage(
                    state: state,
                    child: const SizedBox.shrink(),
                  );
                }
                final child = ChangeNotifierProvider<RomaneioDetalheViewModel>(
                  create: (ctx) => RomaneioDetalheViewModel(
                    ctx.read<RomaneioService>(),
                    ctx.read<PedidoService>(),
                    ctx.read<ProdutoService>(),
                    ctx.read<EmpresaService>(),
                    ctx.read<ClienteService>(),
                    ctx.read<CupomService>(),
                    ctx.read<PdfExportService>(),
                    idRomaneio: id,
                  ),
                  child: const RomaneioDetalhesView(),
                );
                return _fadePage(state: state, child: child);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Inicializa o [PedidoCriarViewModel] com cliente pré-selecionado quando a tela é aberta a partir dos detalhes do cliente.
class _PedidoCriarInicializador extends StatefulWidget {
  const _PedidoCriarInicializador({
    required this.child,
    this.cliente,
  });

  final Widget child;
  final ClienteModel? cliente;

  @override
  State<_PedidoCriarInicializador> createState() =>
      _PedidoCriarInicializadorState();
}

class _PedidoCriarInicializadorState extends State<_PedidoCriarInicializador> {
  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<PedidoCriarViewModel>().inicializarComCliente(widget.cliente!);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

VoidCallback? _listenerRota;

/// Registra o listener que alimenta o histórico do [NavigationController].
/// Remove o listener anterior (ex.: após restart do app) antes de adicionar o novo.
void configurarListenerDeRota(BuildContext context) {
  if (_listenerRota != null) {
    appRouter.routerDelegate.removeListener(_listenerRota!);
  }
  final navController = context.read<NavigationController>();
  _listenerRota = () {
    final config = appRouter.routerDelegate.currentConfiguration;
    final path = config.uri.path;
    final location = path.endsWith('/') && path.length > 1
        ? path.substring(0, path.length - 1)
        : path;
    navController.registrarRota(location);
  };
  appRouter.routerDelegate.addListener(_listenerRota!);
}
