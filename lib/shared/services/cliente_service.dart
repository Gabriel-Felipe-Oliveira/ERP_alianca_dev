import 'package:dio/dio.dart';
import 'package:erp_alianca_dev/core/config/api_config.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/network/api_response.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/core/constants/pagination_constants.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';

class ClienteService {
  final DioClient _dioClient;

  ClienteService(this._dioClient);

  /// Lista clientes da empresa (id_empresa injetado pelo Dio).
  /// [status]: ativa | inativa. [q]: busca por nome. [includeDeleted]: incluir excluídos.
  Future<List<ClienteModel>> listarClientes({
    String? status,
    String? q,
    bool includeDeleted = false,
  }) async {
    final query = <String, dynamic>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (q != null && q.isNotEmpty) query['q'] = q;
    query['include_deleted'] = includeDeleted;

    final response = await _dioClient.get<Object?>(
      'api/clientes.php',
      queryParameters: query.isEmpty ? {} : query,
    );

    return ApiResponseParser.parseList(
      response.data,
      ClienteModel.fromJson,
    );
  }

  /// Lista paginada (?page=&limit=). Fallback client-side se a API retornar tudo.
  Future<PaginatedResult<ClienteModel>> listarClientesPaginado({
    required int page,
    int limit = PaginationConstants.defaultLimit,
    String? status,
    String? q,
    bool includeDeleted = false,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (q != null && q.isNotEmpty) query['q'] = q;
    query['include_deleted'] = includeDeleted;

    final response = await _dioClient.get<Object?>(
      'api/clientes.php',
      queryParameters: query,
    );

    return ApiResponseParser.parsePaginatedList(
      response.data,
      ClienteModel.fromJson,
      requestedPage: page,
      requestedLimit: limit,
    );
  }

  /// Busca um único cliente por id.
  Future<ClienteModel> buscarClientePorId(int id) async {
    final response = await _dioClient.get<Object?>(
      'api/clientes.php',
      queryParameters: {'id_cliente': id},
    );

    return ApiResponseParser.parseRequiredObject(
      response.data,
      ClienteModel.fromJson,
      notFoundMessage: 'Cliente não encontrado.',
    );
  }

  /// Cria cliente na API. Não lê nem valida o corpo da resposta; só considera sucesso se a requisição concluir com status 2xx.
  Future<void> criarCliente(ClienteModel cliente) async {
    try {
      final response = await _dioClient.post<Object?>(
        'api/clientes.php',
        data: cliente.toJson(),
        options: Options(responseType: ResponseType.plain),
      );
      if (!ApiConfig.isSuccessStatusCode(response.statusCode)) {
        throw Exception('Erro ao criar cliente.');
      }
    } on AppException catch (e) {
      if (e.statusCode != null && ApiConfig.isSuccessStatusCode(e.statusCode)) {
        return;
      }
      rethrow;
    }
  }

  /// Atualiza cliente na API (PUT). Body: toJson() do modelo.
  Future<void> atualizarCliente(
    ClienteModel cliente, {
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    if (cliente.id == null) {
      throw Exception('Cliente sem id para atualização.');
    }
    final response = await _dioClient.put<Map<String, dynamic>>(
      'api/clientes.php',
      data: cliente.toJson(),
    );

    ApiResponseParser.requireOk(
      response.data,
      defaultMessage: 'Erro ao atualizar cliente.',
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
      statusCode: response.statusCode,
    );
  }

  /// Arquivar cliente (soft delete). Body: id_cliente, id_empresa.
  Future<void> excluirCliente(
    int idCliente,
    int idEmpresa, {
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    final response = await _dioClient.delete<Map<String, dynamic>>(
      'api/clientes.php',
      data: {
        'id_cliente': idCliente,
        'id_empresa': idEmpresa,
      },
    );

    ApiResponseParser.requireOk(
      response.data,
      defaultMessage: 'Erro ao excluir cliente.',
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
      statusCode: response.statusCode,
    );
  }
}
