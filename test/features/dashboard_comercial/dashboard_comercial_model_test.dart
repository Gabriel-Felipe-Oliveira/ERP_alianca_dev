import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/model/dashboard_comercial_model.dart';

void main() {
  group('DashboardComercialModel', () {
    test('parseia envelope completo da API', () {
      const raw = <String, dynamic>{
        'success': true,
        'ok': true,
        'id_empresa': 1,
        'data': <String, dynamic>{
          'filtros': <String, dynamic>{
            'data_inicio': '2026-06-27',
            'data_fim': '2026-06-27',
            'agrupamento': 'diario',
            'id_produto': null,
            'status_pedido': null,
            'include_deleted': false,
          },
          'cards': <String, dynamic>{
            'total_vendas': 3111.9,
            'total_pedidos': 1,
            'ticket_medio': 3111.9,
            'total_produtos_vendidos': 2,
            'total_clientes_empresas_compradoras': 1,
          },
          'graficos': <String, dynamic>{
            'vendas_por_periodo': [
              <String, dynamic>{'periodo': '2026-06-27', 'total': 3111.9},
            ],
            'pedidos_por_periodo': [
              <String, dynamic>{'periodo': '2026-06-27', 'total': 1},
            ],
            'produtos_mais_vendidos': [
              <String, dynamic>{
                'id_produto': 140,
                'produto': 'KING 193X203',
                'quantidade': 1,
                'valor_total': 1981.99,
              },
            ],
            'produtos_maior_faturamento': [
              <String, dynamic>{
                'id_produto': 140,
                'produto': 'KING 193X203',
                'valor_total': 1981.99,
              },
            ],
            'clientes_mais_compraram': [
              <String, dynamic>{
                'id_cliente': 306,
                'nome': 'ERLON AVELINO',
                'nome_empresa': null,
                'cpf_cnpj': '06004778605',
                'total_pedidos': 1,
                'valor_total': 3111.9,
              },
            ],
          },
          'ultimos_pedidos': [
            <String, dynamic>{
              'id_pedido': 1988,
              'data_pedido': '2026-06-27',
              'status': 'organizado',
              'valor_total': 3111.9,
            },
          ],
        },
      };

      final model = DashboardComercialModel.fromJson(raw);

      expect(model.cards.totalVendas, 3111.9);
      expect(model.cards.totalPedidos, 1);
      expect(model.graficos.vendasPorPeriodo, hasLength(1));
      expect(model.graficos.produtosMaisVendidos.first.produto, 'KING 193X203');
      expect(model.graficos.clientesMaisCompraram.first.nome, 'ERLON AVELINO');
      expect(model.ultimosPedidos.first.idPedido, 1988);
      expect(model.ultimosPedidos.first.status, 'organizado');
    });

    test('toQueryParameters inclui filtros opcionais', () {
      const filtros = DashboardComercialFiltros(
        dataInicio: '2026-06-01',
        dataFim: '2026-06-27',
        agrupamento: 'mensal',
        statusPedido: 'organizado',
        includeDeleted: true,
      );

      final params = filtros.toQueryParameters();

      expect(params['data_inicio'], '2026-06-01');
      expect(params['agrupamento'], 'mensal');
      expect(params['status_pedido'], 'organizado');
      expect(params['include_deleted'], isTrue);
      expect(params.containsKey('id_produto'), isFalse);
    });
  });
}
