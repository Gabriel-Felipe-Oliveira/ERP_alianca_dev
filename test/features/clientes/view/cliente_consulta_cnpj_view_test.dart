import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/theme/empresa_palettes.dart';
import 'package:erp_alianca_dev/features/clientes/view/cliente_consulta_cnpj_view.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/cliente_consulta_cnpj_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/models/app_feedback.dart';
import 'package:erp_alianca_dev/shared/models/cnpj_consulta_model.dart';
import 'package:erp_alianca_dev/shared/services/cnpj_consulta_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

class _FakeCnpjConsultaService extends CnpjConsultaService {
  _FakeCnpjConsultaService(this._handler) : super();

  final Future<CnpjConsultaModel> Function(String cnpj) _handler;

  @override
  Future<CnpjConsultaModel> consultar(String cnpj) => _handler(cnpj);
}

const _cnpjTeste = '12345678000195';

Widget _buildApp(CnpjConsultaService service) {
  final router = GoRouter(
    initialLocation: AppRoutes.clientesConsultaCnpj,
    routes: [
      GoRoute(
        path: AppRoutes.clientesConsultaCnpj,
        builder: (context, state) => Scaffold(
          body: ChangeNotifierProvider(
            create: (_) => ClienteConsultaCnpjViewModel(service),
            child: const ClienteConsultaCnpjView(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.clientesCriar,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Tela criar cliente'))),
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

Future<void> _preencherCnpj(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), _cnpjTeste);
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppColors.setCurrent(EmpresaPalettes.getById(kDefaultIdEmpresa));
  });

  group('ClienteConsultaCnpjView feedback', () {
    testWidgets('erro da API exibe overlay e não navega', (tester) async {
      const mensagemErro = 'CNPJ não encontrado na base da Receita Federal.';
      await tester.pumpWidget(
        _buildApp(
          _FakeCnpjConsultaService(
            (_) async => throw const AppException(message: mensagemErro),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _preencherCnpj(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Buscar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(mensagemErro), findsOneWidget);
      expect(find.text('Erro'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Tela criar cliente'), findsNothing);

      await tester.pump(AppFeedbackDurations.error);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('sucesso navega sem exibir overlay', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          _FakeCnpjConsultaService(
            (_) async => const CnpjConsultaModel(
              cnpj: _cnpjTeste,
              razaoSocial: 'Empresa Teste LTDA',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _preencherCnpj(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Buscar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Tela criar cliente'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('CNPJ incompleto mantém botão desativado', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          _FakeCnpjConsultaService(
            (_) async => throw StateError('Não deveria chamar a API'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      final botao = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Buscar'),
      );
      expect(botao.onPressed, isNull);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(find.text('Tela criar cliente'), findsNothing);
    });
  });
}
