import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/shared/models/dashboard_totais_model.dart';

void main() {
  group('DashboardTotaisModel', () {
    test('fromJson parseia resumo de pedidos', () {
      final model = DashboardTotaisModel.fromJson({
        'success': true,
        'ok': true,
        'data': {
          'totais': {
            'pedidos': {
              'resumo': {
                'quantidade': 152,
                'valor_total': 48750.9,
              },
            },
            'romaneios': {
              'resumo': {
                'quantidade': 25,
                'valor_total': 1000,
              },
            },
          },
        },
      });

      expect(model.pedidos.resumo.quantidade, 152);
      expect(model.pedidos.resumo.valorTotal, 48750.9);
      expect(model.romaneios.resumo.quantidade, 25);
    });

    test('fromJson retorna vazio quando envelope inválido', () {
      expect(DashboardTotaisModel.fromJson(null), DashboardTotaisModel.vazio);
      expect(DashboardTotaisModel.fromJson({}), DashboardTotaisModel.vazio);
    });
  });

  group('DashboardTotaisFiltros', () {
    test('toQueryParameters envia status quando informado', () {
      const filtros = DashboardTotaisFiltros(status: 'confirmado');
      expect(filtros.toQueryParameters(), {'status': 'confirmado'});
    });
  });
}
