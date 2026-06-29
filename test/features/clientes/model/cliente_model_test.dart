import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';

void main() {
  group('ClienteModel data_nascimento', () {
    test('toJson inclui data_nascimento em dd/MM/yyyy', () {
      final model = ClienteModel(
        idEmpresa: 1,
        nome: 'João Silva',
        telefone: '31999999999',
        email: 'joao@test.com',
        cep: '32600000',
        logradouro: 'Rua A',
        numero: '1',
        bairro: 'Centro',
        cidade: 'Betim',
        estado: 'MG',
        dataNascimento: DateTime(1985, 7, 20),
      );

      final json = model.toJson();
      expect(json['data_nascimento'], '20/07/1985');
    });

    test('toJson omite data_nascimento quando nula', () {
      final model = ClienteModel(
        idEmpresa: 1,
        nome: 'João Silva',
        telefone: '',
        email: '',
        cep: '',
        logradouro: '',
        numero: '',
        bairro: '',
        cidade: '',
        estado: 'MG',
      );

      expect(model.toJson().containsKey('data_nascimento'), isFalse);
    });

    test('fromJson parseia data_nascimento', () {
      final model = ClienteModel.fromJson({
        'id_cliente': 1,
        'id_empresa': 1,
        'nome': 'Maria',
        'telefone': '',
        'email_principal': '',
        'cep': '',
        'logradouro': '',
        'numero': '',
        'bairro': '',
        'cidade': '',
        'estado': 'MG',
        'status': 'ativa',
        'data_nascimento': '10/01/2000',
      });

      expect(model.dataNascimento, DateTime(2000, 1, 10));
    });
  });

  group('ClienteModel CNPJ payload', () {
    test('toJson envia nome_empresa sem nome_responsavel no fluxo novo', () {
      final model = ClienteModel(
        idEmpresa: 1,
        tipoDocumento: 'cnpj',
        documento: '12345678000190',
        nome: 'Carlos Responsável',
        nomeEmpresa: 'Empresa LTDA',
        telefone: '',
        email: '',
        cep: '',
        logradouro: '',
        numero: '',
        bairro: '',
        cidade: '',
        estado: 'MG',
      );

      final json = model.toJson();
      expect(json['nome'], 'Carlos Responsável');
      expect(json['nome_empresa'], 'Empresa LTDA');
      expect(json.containsKey('nome_responsavel'), isFalse);
    });
  });
}
