import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/core/constants/realtime_constants.dart';
import 'package:erp_alianca_dev/core/theme/empresa_palettes.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/models/realtime_notification_model.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/realtime_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

import '../../helpers/mock_dio_client.dart';
import 'package:erp_alianca_dev/shared/viewmodels/notifications_viewmodel.dart';
import 'package:erp_alianca_dev/shared/widgets/realtime_notification_listener.dart';

class _TestNotificationsViewModel extends NotificationsViewModel {
  _TestNotificationsViewModel()
      : super(
          RealtimeService(),
          createTestAuthService(EmpresaService()),
          EmpresaService(),
        );

  void emit(RealtimeNotificationModel notification) =>
      debugSetPending(notification);
}

Widget _buildApp(_TestNotificationsViewModel notificationsVm) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => RealtimeNotificationListener(
          child: Scaffold(
            body: Center(
              child: Text('Home', key: Key('home-body')),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.pedidosDetalhes}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return Scaffold(body: Text('Pedido $id'));
        },
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    builder: (context, child) => ChangeNotifierProvider<NotificationsViewModel>.value(
      value: notificationsVm,
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppColors.setCurrent(EmpresaPalettes.getById(kDefaultIdEmpresa));
  });

  testWidgets('RealtimeNotificationListener exibe feedback padronizado', (tester) async {
    final notificationsVm = _TestNotificationsViewModel();
    await tester.pumpWidget(_buildApp(notificationsVm));
    await tester.pumpAndSettle();

    notificationsVm.emit(
      RealtimeNotificationModel(
        type: RealtimeConstants.eventPedidoAbertoLongo,
        mensagem: 'Pedido #42 aguardando há muito tempo.',
        payload: {'id_pedido': 42, 'id_usuario': 1},
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Notificação'), findsOneWidget);
    expect(find.text('Pedido #42 aguardando há muito tempo.'), findsOneWidget);
    expect(find.text('Ver pedido'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    notificationsVm.dispose();
  });
}
