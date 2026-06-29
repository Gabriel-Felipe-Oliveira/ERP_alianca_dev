import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/core/constants/app_constants.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/core/platform/erp_widgets_binding.dart';
import 'package:erp_alianca_dev/core/platform/windows_keyboard_fix.dart';
import 'package:erp_alianca_dev/core/platform/windows_semantics_guard.dart';
import 'package:erp_alianca_dev/core/theme/empresa_palettes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/models/empresa_palette_model.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/clientes_viewmodel.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedidos_viewmodel.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produtos_viewmodel.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_viewmodel.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/viewmodel/dashboard_comercial_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/routes/app_router.dart';
import 'package:erp_alianca_dev/shared/services/auth_storage_service.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/cnpj_consulta_service.dart';
import 'package:erp_alianca_dev/shared/services/cupom_service.dart';
import 'package:erp_alianca_dev/shared/services/dashboard_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/local_storage_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/pdf_export_service.dart';
import 'package:erp_alianca_dev/shared/services/realtime_service.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';
import 'package:erp_alianca_dev/shared/utils/app_hard_restart.dart';
import 'package:erp_alianca_dev/shared/utils/pdf_utils.dart';
import 'package:erp_alianca_dev/shared/viewmodels/navigation_controller.dart';
import 'package:erp_alianca_dev/shared/viewmodels/notifications_viewmodel.dart';
import 'package:erp_alianca_dev/shared/viewmodels/theme_palette_provider.dart';
import 'package:erp_alianca_dev/shared/widgets/app_palette_scope.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  ErpWidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await Future<void>.delayed(Duration.zero);

  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    minimumSize: Size(900, 600),
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
  });
  await WindowsKeyboardFix.install();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await windowManager.focus();
    WindowsKeyboardFix.syncNow();
  });

  final localStorageService = LocalStorageService();
  await localStorageService.init();

  await garantirPastasPdfCriadas();

  final authStorageService = AuthStorageService(localStorageService);
  final empresaService = EmpresaService();
  final authService = AuthService(
    authStorage: authStorageService,
    empresaService: empresaService,
    localStorageService: localStorageService,
  );
  await authService.restoreSession();

  initAppRouter(authService);

  final dioClient = DioClient(empresaService, authService);
  final clienteService = ClienteService(dioClient);
  final pedidoService = PedidoService(dioClient);
  final romaneioService = RomaneioService(dioClient);
  final dashboardService = DashboardService(dioClient);
  final produtoService = ProdutoService(dioClient);
  final cupomService = CupomService();
  final pdfExportService = PdfExportService();
  final cnpjConsultaService = CnpjConsultaService();
  final realtimeService = RealtimeService();

  final basePalette = EmpresaPalettes.getById(empresaService.idEmpresa);
  final isLightMode =
      localStorageService.getBool(LocalStorageService.themeLightModeKey) ??
          false;
  AppColors.setCurrent(
    isLightMode ? EmpresaPalette.lightFrom(basePalette) : basePalette,
  );

  runApp(
    WindowsSemanticsGuard(
      child: VendasBaseApp(
        localStorageService: localStorageService,
        authService: authService,
        empresaService: empresaService,
        dioClient: dioClient,
        clienteService: clienteService,
        pedidoService: pedidoService,
        produtoService: produtoService,
        romaneioService: romaneioService,
        dashboardService: dashboardService,
        cupomService: cupomService,
        pdfExportService: pdfExportService,
        cnpjConsultaService: cnpjConsultaService,
        realtimeService: realtimeService,
      ),
    ),
  );
}

class VendasBaseApp extends StatefulWidget {
  final LocalStorageService localStorageService;
  final AuthService authService;
  final EmpresaService empresaService;
  final DioClient dioClient;
  final ClienteService clienteService;
  final PedidoService pedidoService;
  final ProdutoService produtoService;
  final RomaneioService romaneioService;
  final DashboardService dashboardService;
  final CupomService cupomService;
  final PdfExportService pdfExportService;
  final CnpjConsultaService cnpjConsultaService;
  final RealtimeService realtimeService;

  const VendasBaseApp({
    super.key,
    required this.localStorageService,
    required this.authService,
    required this.empresaService,
    required this.dioClient,
    required this.clienteService,
    required this.pedidoService,
    required this.produtoService,
    required this.romaneioService,
    required this.dashboardService,
    required this.cupomService,
    required this.pdfExportService,
    required this.cnpjConsultaService,
    required this.realtimeService,
  });

  @override
  State<VendasBaseApp> createState() => _VendasBaseAppState();
}

class _VendasBaseAppState extends State<VendasBaseApp> {
  int _softRestartKey = 0;

  @override
  void initState() {
    super.initState();
    AppHardRestart.registerSoftRestartFallback(_softRestart);
  }

  Future<void> _softRestart() async {
    appRouter.go(
      widget.authService.isAuthenticated ? AppRoutes.home : AppRoutes.login,
    );
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      try {
        ctx.read<NavigationController>().limparHistorico();
      } catch (_) {}
    }
    if (mounted) {
      setState(() => _softRestartKey++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStorageService>.value(value: widget.localStorageService),
        ChangeNotifierProvider<AuthService>.value(value: widget.authService),
        ChangeNotifierProvider<EmpresaService>.value(value: widget.empresaService),
        Provider<DioClient>.value(value: widget.dioClient),
        Provider<ClienteService>.value(value: widget.clienteService),
        Provider<PedidoService>.value(value: widget.pedidoService),
        Provider<ProdutoService>.value(value: widget.produtoService),
        Provider<RomaneioService>.value(value: widget.romaneioService),
        Provider<DashboardService>.value(value: widget.dashboardService),
        Provider<CupomService>.value(value: widget.cupomService),
        Provider<PdfExportService>.value(value: widget.pdfExportService),
        Provider<CnpjConsultaService>.value(value: widget.cnpjConsultaService),
        Provider<RealtimeService>.value(value: widget.realtimeService),
      ],
      child: KeyedSubtree(
        key: ValueKey<int>(_softRestartKey),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<NavigationController>(
              create: (_) => NavigationController(),
            ),
            ChangeNotifierProvider<ClientesViewModel>(
              create: (context) =>
                  ClientesViewModel(context.read<ClienteService>()),
            ),
            ChangeNotifierProvider<ProdutosViewModel>(
              create: (ctx) => ProdutosViewModel(ctx.read<ProdutoService>()),
            ),
            ChangeNotifierProvider<PedidosViewModel>(
              create: (ctx) => PedidosViewModel(
                ctx.read<PedidoService>(),
                ctx.read<ClienteService>(),
              ),
            ),
            ChangeNotifierProvider<RomaneioViewModel>(
              create: (ctx) => RomaneioViewModel(ctx.read<RomaneioService>()),
            ),
            ChangeNotifierProvider<DashboardComercialViewModel>(
              create: (ctx) =>
                  DashboardComercialViewModel(ctx.read<DashboardService>()),
            ),
            ChangeNotifierProvider<ThemePaletteProvider>(
              create: (ctx) => ThemePaletteProvider(
                ctx.read<EmpresaService>(),
                ctx.read<LocalStorageService>(),
              ),
            ),
            ChangeNotifierProvider<NotificationsViewModel>(
              create: (ctx) => NotificationsViewModel(
                ctx.read<RealtimeService>(),
                ctx.read<AuthService>(),
                ctx.read<EmpresaService>(),
              ),
            ),
          ],
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                configurarListenerDeRota(context);
              });
              final themePalette = context.watch<ThemePaletteProvider>();
              return MaterialApp.router(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                locale: const Locale('pt', 'BR'),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('pt', 'BR'),
                ],
                theme: themePalette.lightThemeData,
                darkTheme: themePalette.darkThemeData,
                themeMode: themePalette.themeMode,
                routerConfig: appRouter,
                builder: (context, child) {
                  return AppPaletteScope(
                    isLightMode: themePalette.isLightMode,
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
