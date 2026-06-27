import 'package:dio/dio.dart';
import 'package:erp_alianca_dev/core/config/api_config.dart';
import 'package:erp_alianca_dev/core/network/api_response.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/core/constants/pagination_constants.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';

/// Serviço de produtos. [id_empresa] é injetado pelo Dio nas queries.
class ProdutoService {
  final DioClient _dioClient;

  ProdutoService(this._dioClient);

  static const String _pathProdutos = 'api/produtos.php';

  /// Busca um produto por ID. Retorna null se 404 (ex.: produto arquivado).
  Future<ProdutoModel?> buscarPorId(int idProduto) async {
    final response = await _dioClient.get<Object?>(
      _pathProdutos,
      queryParameters: <String, dynamic>{'id_produto': idProduto},
      options: Options(
        validateStatus: (status) =>
            status != null && (status == 200 || status == 404),
      ),
    );
    if (response.statusCode == 404) return null;
    return ApiResponseParser.parseObject(
      response.data,
      ProdutoModel.fromJson,
      rootEntityKeys: ['nome', 'id_produto'],
    );
  }

  /// Lista produtos. [status] opcional: ativo | inativo. [q] opcional: busca por nome.
  Future<List<ProdutoModel>> listar({
    String? status,
    String? q,
    bool includeDeleted = false,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (q != null && q.isNotEmpty) queryParams['q'] = q;
    if (includeDeleted) queryParams['include_deleted'] = true;

    final response = await _dioClient.get<Object?>(
      _pathProdutos,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return ApiResponseParser.parseList(
      response.data,
      ProdutoModel.fromJson,
    );
  }

  /// Lista paginada (?page=&limit=).
  Future<PaginatedResult<ProdutoModel>> listarPaginado({
    required int page,
    int limit = PaginationConstants.defaultLimit,
    String? status,
    String? q,
    bool includeDeleted = false,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (q != null && q.isNotEmpty) queryParams['q'] = q;
    if (includeDeleted) queryParams['include_deleted'] = true;

    final response = await _dioClient.get<Object?>(
      _pathProdutos,
      queryParameters: queryParams,
    );

    return ApiResponseParser.parsePaginatedList(
      response.data,
      ProdutoModel.fromJson,
      requestedPage: page,
      requestedLimit: limit,
    );
  }

  /// Atualiza produto na API (PUT).
  Future<void> atualizar(
    ProdutoModel produto, {
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    if (produto.idProduto == null) {
      throw Exception('Produto sem id para atualização.');
    }
    final response = await _dioClient.put<Map<String, dynamic>>(
      _pathProdutos,
      data: {
        'id_produto': produto.idProduto,
        'id_empresa': produto.idEmpresa,
        'nome': produto.nome,
        'preco': produto.preco,
        'estoque_atual': produto.estoqueAtual,
        'status': produto.status,
      },
    );

    ApiResponseParser.requireOk(
      response.data,
      defaultMessage: 'Erro ao atualizar produto',
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
      statusCode: response.statusCode,
    );
  }

  /// Arquivar produto (soft delete). Body: id_produto, id_empresa.
  Future<void> arquivar(
    int idProduto,
    int idEmpresa, {
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    final response = await _dioClient.delete<Map<String, dynamic>>(
      _pathProdutos,
      data: {
        'id_produto': idProduto,
        'id_empresa': idEmpresa,
      },
    );

    ApiResponseParser.requireOk(
      response.data,
      defaultMessage: 'Erro ao arquivar produto',
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
      statusCode: response.statusCode,
    );
  }

  /// Cria produto. Retorna o [id_produto] em caso de sucesso (201).
  Future<int> criar(
    ProdutoModel produto, {
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      _pathProdutos,
      data: produto.toJson(),
    );

    final data = response.data;
    if (data == null) {
      if (allowEmptyResponseOnSuccess &&
          ApiConfig.isSuccessStatusCode(response.statusCode)) {
        return 0;
      }
      throw Exception('Resposta inválida da API');
    }

    ApiResponseParser.requireOk(
      data,
      defaultMessage: 'Erro ao criar produto',
    );

    final idProduto = data['id_produto'];
    if (idProduto == null) {
      throw Exception(
        ApiResponseParser.message(data) ?? 'Erro ao criar produto',
      );
    }
    return idProduto is int ? idProduto : int.parse(idProduto.toString());
  }
}
