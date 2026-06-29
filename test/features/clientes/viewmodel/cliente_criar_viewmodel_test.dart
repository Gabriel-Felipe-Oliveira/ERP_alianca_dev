import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/clientes/utils/cliente_validator.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/cliente_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';

import '../../../helpers/mock_dio_client.dart';

DioClient _bareClient() =>
    DioClient(EmpresaService(), createTestAuthService(EmpresaService()));

class _CapturingClienteService extends ClienteService {
  _CapturingClienteService() : super(_bareClient());

  ClienteModel? ultimoCliente;

  @override
  Future<void> criarCliente(ClienteModel cliente) async {
    ultimoCliente = cliente;
  }
}

Future<void> _pumpForm(WidgetTester tester, ClienteCriarViewModel vm) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: vm.formKey,
          child: TextFormField(
            controller: vm.nomeController,
            validator: ClienteValidator.nomeCriar(vm.isCpf),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('ClienteCriarViewModel', () {
    late _CapturingClienteService clienteService;
    late EmpresaService empresaService;
    late ClienteCriarViewModel vm;

    setUp(() {
      clienteService = _CapturingClienteService();
      empresaService = EmpresaService();
      vm = ClienteCriarViewModel(clienteService, empresaService);
    });

    tearDown(() => vm.dispose());

    testWidgets('salvar CNPJ mapeia nome completo e nome empresa corretamente',
        (tester) async {
      vm.isCpf = false;
      vm.nomeController.text = 'Carlos Responsável';
      vm.nomeResponsavelController.text = 'Empresa LTDA';
      vm.documentController.text = '12.345.678/0001-90';
      vm.dataNascimento = DateTime(1990, 5, 10);
      await _pumpForm(tester, vm);

      final ok = await vm.salvar();

      expect(ok, isTrue);
      final salvo = clienteService.ultimoCliente!;
      expect(salvo.tipoDocumento, 'cnpj');
      expect(salvo.nome, 'Carlos Responsável');
      expect(salvo.nomeEmpresa, 'Empresa LTDA');
      expect(salvo.nomeResponsavel, isNull);
      expect(salvo.dataNascimento, DateTime(1990, 5, 10));
    });

    testWidgets('salvar CPF envia data de nascimento quando preenchida',
        (tester) async {
      vm.nomeController.text = 'Maria Souza';
      vm.dataNascimento = DateTime(1988, 12, 1);
      await _pumpForm(tester, vm);

      final ok = await vm.salvar();

      expect(ok, isTrue);
      expect(clienteService.ultimoCliente!.dataNascimento, DateTime(1988, 12, 1));
    });
  });
}
