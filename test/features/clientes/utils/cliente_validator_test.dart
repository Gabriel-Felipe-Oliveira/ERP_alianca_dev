import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/features/clientes/utils/cliente_validator.dart';

void main() {
  group('ClienteValidator nomeCriar', () {
    test('usa label Nome completo para CPF e CNPJ', () {
      final validarCpf = ClienteValidator.nomeCriar(true);
      final validarCnpj = ClienteValidator.nomeCriar(false);

      expect(validarCpf(''), isNotNull);
      expect(validarCnpj(''), isNotNull);
      expect(validarCpf('João'), isNull);
      expect(validarCnpj('Empresa X'), isNull);
    });
  });

  group('ClienteValidator camposFaltantesCriar', () {
    test('retorna Nome completo independente do tipo de documento', () {
      expect(ClienteValidator.camposFaltantesCriar(true, ''), ['Nome completo']);
      expect(ClienteValidator.camposFaltantesCriar(false, ''), ['Nome completo']);
      expect(ClienteValidator.camposFaltantesCriar(false, 'João'), isEmpty);
    });
  });
}
