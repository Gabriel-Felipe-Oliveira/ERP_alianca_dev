import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/features/pedidos/utils/pedido_confirmacao_erro.dart';

void main() {
  group('PedidoConfirmacaoErro.mensagem', () {
    test('prioriza error do body da API', () {
      const ex = AppException(
        message: 'Erro genérico',
        data: {'error': 'Estoque insuficiente para produto 1'},
      );
      expect(
        PedidoConfirmacaoErro.mensagem(ex),
        'Estoque insuficiente para produto 1',
      );
    });

    test('usa message do AppException quando body vazio', () {
      const ex = AppException(message: 'Falha na rede');
      expect(PedidoConfirmacaoErro.mensagem(ex), 'Falha na rede');
    });

    test('extrai texto de Exception genérica', () {
      expect(
        PedidoConfirmacaoErro.mensagem(Exception('timeout')),
        'timeout',
      );
    });

    test('retorna mensagem genérica para erro não-Exception', () {
      expect(
        PedidoConfirmacaoErro.mensagem('erro desconhecido'),
        'Erro ao confirmar pedido. Tente novamente.',
      );
    });
  });
}
