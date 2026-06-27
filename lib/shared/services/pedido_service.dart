import 'package:erp_alianca_dev/core/config/api_config.dart';
import 'package:erp_alianca_dev/core/network/api_response.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/core/constants/pagination_constants.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';

/// Serviço de pedidos: listar, criar pedido e adicionar itens.
/// [id_empresa] é injetado pelo Dio nas queries GET.
class PedidoService {
  final DioClient _dioClient;

  PedidoService(this._dioClient);

  static const String _pathPedidos = 'api/pedidos.php';
  static const String _pathPedidoItens = 'api/pedido_itens.php';

  /// Lista pedidos. GET api/pedidos.php (id_empresa injetado).
  /// [status]: rascunho, aguardando_confirmacao, confirmado, concluido, cancelado.
  Future<List<PedidoListagemModel>> listarPedidos({
    String? status,
    int? idCliente,
  }) async {
    final query = <String, dynamic>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (idCliente != null) query['id_cliente'] = idCliente;

    final response = await _dioClient.get<Object?>(
      _pathPedidos,
      queryParameters: query.isEmpty ? {} : query,
    );

    return ApiResponseParser.parseList(
      response.data,
      PedidoListagemModel.fromJson,
    );
  }

  /// Lista pedidos paginados (?page=&limit=).
  Future<PaginatedResult<PedidoListagemModel>> listarPedidosPaginado({
    required int page,
    int limit = PaginationConstants.defaultLimit,
    String? status,
    int? idCliente,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (idCliente != null) query['id_cliente'] = idCliente;

    final response = await _dioClient.get<Object?>(
      _pathPedidos,
      queryParameters: query,
    );

    return ApiResponseParser.parsePaginatedList(
      response.data,
      PedidoListagemModel.fromJson,
      requestedPage: page,
      requestedLimit: limit,
    );
  }

  /// Lista pedidos por IDs. Faz uma requisição por id_pedido (a API retorna um pedido por vez).
  /// Útil para montar o corpo dos pedidos de um romaneio.
  Future<List<PedidoListagemModel>> listarPedidosPorIds(
    List<int> ids,
  ) async {
    if (ids.isEmpty) return [];
    final result = <PedidoListagemModel>[];
    for (final id in ids) {
      try {
        final response = await _dioClient.get<Object?>(
          _pathPedidos,
          queryParameters: <String, dynamic>{'id_pedido': id},
        );
        final maps = ApiResponseParser.extractMaps(response.data);
        for (final map in maps) {
          result.add(PedidoListagemModel.fromJson(map));
          break;
        }
      } catch (_) {
        // Ignora erro em um id e segue para o próximo
      }
    }
    // Garantir ordem igual à dos ids solicitados
    final byId = {for (final p in result) p.idPedido: p};
    return ids.map((id) => byId[id]).whereType<PedidoListagemModel>().toList();
  }

  /// Cria o pedido. Retorna [id_pedido] em sucesso (201).
  /// [allowEmptyResponseOnSuccess]: se true, 2xx com body null é tratado como sucesso (retorna 0).
  Future<int> criarPedido(
    PedidoCriarPayload payload, {
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      _pathPedidos,
      data: payload.toJson(),
    );

    final data = response.data;
    if (data == null) {
      if (allowEmptyResponseOnSuccess &&
          ApiConfig.isSuccessStatusCode(response.statusCode)) {
        return 0;
      }
      throw Exception('Resposta inválida ao criar pedido.');
    }
    final idPedido = PedidoCriarPayload.idPedidoFromResponse(data);
    if (idPedido == null) {
      throw Exception(
        (data['message'] is String)
            ? data['message'] as String
            : 'Resposta inválida ao criar pedido.',
      );
    }
    return idPedido;
  }

  /// Lista itens do pedido. GET api/pedido_itens.php?id_pedido=...
  /// [id_empresa] é injetado pelo Dio nas queries.
  Future<List<PedidoItemModel>> listarItensPedido(int idPedido) async {
    final response = await _dioClient.get<Object?>(
      _pathPedidoItens,
      queryParameters: <String, dynamic>{'id_pedido': idPedido},
    );

    return ApiResponseParser.parseList(
      response.data,
      PedidoItemModel.fromJson,
    );
  }

  /// Alterar status do pedido. PATCH api/pedidos.php com action "set_status".
  /// O total do pedido fica a cargo do backend (soma de quantidade × valor de cada item).
  /// [pagamento]: quando informado, enviado no mesmo PATCH (API aceita apenas `restore`|`set_status`).
  /// [allowEmptyResponseOnSuccess]: se true, 2xx com body null é tratado como sucesso.
  Future<void> alterarStatusPedido(
    int idPedido,
    int idEmpresa,
    String status, {
    String? pagamento,
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    final payload = <String, dynamic>{
      'id_pedido': idPedido,
      'id_empresa': idEmpresa,
      'action': 'set_status',
      'status': status,
    };
    final p = pagamento?.trim();
    if (p != null && p.isNotEmpty) {
      payload['pagamento'] = p;
    }

    final response = await _dioClient.patch<Map<String, dynamic>>(
      _pathPedidos,
      data: payload,
    );

    final data = response.data;
    if (data == null) {
      if (allowEmptyResponseOnSuccess &&
          ApiConfig.isSuccessStatusCode(response.statusCode)) {
        return;
      }
      throw Exception('Resposta inválida ao alterar status.');
    }
    ApiResponseParser.requireOk(
      data,
      defaultMessage: 'Erro ao alterar status do pedido.',
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
      statusCode: response.statusCode,
    );
  }

  /// Atualiza só a forma de pagamento: mesmo PATCH de [alterarStatusPedido] com o [statusAtual] inalterado.
  Future<void> atualizarPagamentoPedido(
    int idPedido,
    int idEmpresa,
    String statusAtual,
    String pagamento, {
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    await alterarStatusPedido(
      idPedido,
      idEmpresa,
      statusAtual,
      pagamento: pagamento,
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
    );
  }

  /// Arquivar pedido. DELETE api/pedidos.php com id_pedido e id_empresa (query e body).
  /// [allowEmptyResponseOnSuccess]: se true, 2xx com body null é tratado como sucesso (retorna 0).
  Future<int> arquivarPedido(
    int idPedido,
    int idEmpresa, {
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    final response = await _dioClient.delete<Map<String, dynamic>>(
      _pathPedidos,
      queryParameters: <String, dynamic>{
        'id_pedido': idPedido,
        'id_empresa': idEmpresa,
      },
      data: <String, dynamic>{
        'id_pedido': idPedido,
        'id_empresa': idEmpresa,
      },
    );

    final data = response.data;
    if (data == null) {
      if (allowEmptyResponseOnSuccess &&
          ApiConfig.isSuccessStatusCode(response.statusCode)) {
        return 0;
      }
      throw Exception('Resposta inválida ao arquivar pedido.');
    }
    ApiResponseParser.requireOk(
      data,
      defaultMessage: 'Erro ao arquivar pedido.',
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
      statusCode: response.statusCode,
    );
    final rows = data['rows_affected'];
    if (rows is int) return rows;
    if (rows is num) return rows.toInt();
    return 0;
  }

  /// Adiciona ou atualiza item do pedido.
  /// [allowEmptyResponseOnSuccess]: se true, 2xx com body null é tratado como sucesso.
  Future<void> adicionarItem(
    PedidoItemPayload payload, {
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      _pathPedidoItens,
      queryParameters: <String, dynamic>{
        'id_pedido': payload.idPedido,
      },
      data: payload.toJson(),
    );

    final data = response.data;
    if (data == null) {
      if (allowEmptyResponseOnSuccess &&
          ApiConfig.isSuccessStatusCode(response.statusCode)) {
        return;
      }
      throw Exception('Resposta inválida ao adicionar item.');
    }
    ApiResponseParser.requireOk(
      data,
      defaultMessage: 'Erro ao adicionar item ao pedido.',
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
      statusCode: response.statusCode,
    );
  }

  /// Remover item do pedido. DELETE api/pedido_itens.php com body id_item e id_empresa.
  /// [allowEmptyResponseOnSuccess]: se true, 2xx com body null é tratado como sucesso.
  Future<void> removerItem(
    int idItem,
    int idEmpresa, {
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    final response = await _dioClient.delete<Map<String, dynamic>>(
      _pathPedidoItens,
      data: <String, dynamic>{
        'id_item': idItem,
        'id_empresa': idEmpresa,
      },
    );

    final data = response.data;
    if (data == null) {
      if (allowEmptyResponseOnSuccess &&
          ApiConfig.isSuccessStatusCode(response.statusCode)) {
        return;
      }
      throw Exception('Resposta inválida ao remover item.');
    }
    ApiResponseParser.requireOk(
      data,
      defaultMessage: 'Erro ao remover item.',
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
      statusCode: response.statusCode,
    );
  }

  /// Atualizar quantidade e/ou valor unitário de item. PUT api/pedido_itens.php.
  /// [valorDesconto]: quando informado, envia valor_desconto (preço unitário de venda).
  /// [allowEmptyResponseOnSuccess]: se true, 2xx com body null é tratado como sucesso.
  Future<void> atualizarQuantidadeItem(
    int idItem,
    int idEmpresa,
    int quantidade, {
    double? valorDesconto,
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    final dataPayload = <String, dynamic>{
      'id_item': idItem,
      'id_empresa': idEmpresa,
      'quantidade': quantidade,
    };
    if (valorDesconto != null) {
      dataPayload['valor_desconto'] = valorDesconto;
    }
    final response = await _dioClient.put<Map<String, dynamic>>(
      _pathPedidoItens,
      data: dataPayload,
    );

    final data = response.data;
    if (data == null) {
      if (allowEmptyResponseOnSuccess &&
          ApiConfig.isSuccessStatusCode(response.statusCode)) {
        return;
      }
      throw Exception('Resposta inválida ao atualizar quantidade.');
    }
    ApiResponseParser.requireOk(
      data,
      defaultMessage: 'Erro ao atualizar quantidade.',
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
      statusCode: response.statusCode,
    );
  }
}
