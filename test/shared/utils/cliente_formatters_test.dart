import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/shared/utils/cliente_formatters.dart';

ClienteModel _cliente({
  String logradouro = 'Rua A',
  String numero = '100',
  String bairro = 'Centro',
  String cidade = 'SP',
  String estado = 'SP',
  String cep = '01000-000',
}) {
  return ClienteModel(
    id: 1,
    idEmpresa: 1,
    nome: 'joao silva',
    telefone: '',
    email: '',
    logradouro: logradouro,
    numero: numero,
    bairro: bairro,
    cidade: cidade,
    estado: estado,
    cep: cep,
  );
}

void main() {
  group('capitalizeWords', () {
    test('capitaliza palavras', () {
      expect(capitalizeWords('joao silva'), 'Joao Silva');
    });
  });

  group('formatarEnderecoDisplay', () {
    test('junta partes com separador', () {
      final endereco = formatarEnderecoDisplay(_cliente());
      expect(endereco, contains('Rua A, 100'));
      expect(endereco, contains('Centro'));
      expect(endereco, contains('SP/SP'));
      expect(endereco, contains('CEP 01000-000'));
    });
  });

  group('formatarEnderecoRecibo', () {
    test('formata em linhas para PDF', () {
      final endereco = formatarEnderecoRecibo(_cliente());
      expect(endereco, contains('Endereço: Rua A, 100'));
      expect(endereco, contains('\n'));
    });
  });
}
