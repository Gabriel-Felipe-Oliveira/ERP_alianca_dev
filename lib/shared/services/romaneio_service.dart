import 'package:erp_alianca_dev/core/config/api_config.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/network/api_response.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/core/constants/pagination_constants.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';

/// Resultado da criação de romaneio na API (201).
class RomaneioCriarResult {
  const RomaneioCriarResult({
    required this.idRomaneio,
    required this.qtdPedidos,
  });
  final int idRomaneio;
  final int qtdPedidos;
}

/// Serviço de romaneio: listar, detalhar e criar.
/// [id_empresa] é injetado pelo Dio nas queries.
class RomaneioService {
  static const String _pathRomaneios = 'api/romaneios.php';

  final DioClient _dioClient;

  RomaneioService(this._dioClient);

  /// Lista romaneios. GET api/romaneios.php (id_empresa injetado).
  /// [status]: rascunho, em_rota, concluido, cancelado. [includeDeleted]: incluir excluídos.
  Future<List<RomaneioModel>> listarRomaneios({
    String? status,
    bool includeDeleted = false,
  }) async {
    final query = <String, dynamic>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    query['include_deleted'] = includeDeleted;

    final response = await _dioClient.get<Object?>(
      _pathRomaneios,
      queryParameters: query,
    );

    return ApiResponseParser.parseList(
      response.data,
      RomaneioModel.fromJson,
      nestedKey: 'romaneio',
    );
  }

  /// Lista romaneios paginados (?page=&limit=).
  Future<PaginatedResult<RomaneioModel>> listarRomaneiosPaginado({
    required int page,
    int limit = PaginationConstants.defaultLimit,
    String? status,
    bool includeDeleted = false,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) query['status'] = status;
    query['include_deleted'] = includeDeleted;

    final response = await _dioClient.get<Object?>(
      _pathRomaneios,
      queryParameters: query,
    );

    return ApiResponseParser.parsePaginatedList(
      response.data,
      RomaneioModel.fromJson,
      requestedPage: page,
      requestedLimit: limit,
      nestedKey: 'romaneio',
    );
  }

  /// Detalha um romaneio. GET api/romaneios.php?id_romaneio=X (id_empresa injetado).
  /// Retorna null se 404 ou resposta vazia.
  Future<RomaneioModel?> obterRomaneio(int idRomaneio) async {
    try {
      final response = await _dioClient.get<Object?>(
        _pathRomaneios,
        queryParameters: <String, dynamic>{'id_romaneio': idRomaneio},
      );
      return ApiResponseParser.parseObject(
        response.data,
        RomaneioModel.fromJson,
      );
    } on AppException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Alterar status do romaneio. PATCH api/romaneios.php body: id_empresa, id_romaneio, action: "set_status", status.
  /// [allowEmptyResponseOnSuccess]: se true, 2xx com body null é tratado como sucesso.
  Future<void> alterarStatusRomaneio({
    required int idEmpresa,
    required int idRomaneio,
    required String status,
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    final response = await _dioClient.patch<Map<String, dynamic>>(
      _pathRomaneios,
      data: <String, dynamic>{
        'id_empresa': idEmpresa,
        'id_romaneio': idRomaneio,
        'action': 'set_status',
        'status': status,
      },
    );
    _requireOk(
      response.data,
      defaultMessage: 'Erro ao alterar status do romaneio.',
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
      statusCode: response.statusCode,
      invalidMessage: 'Resposta inválida ao alterar status.',
    );
  }

  /// Atualiza romaneio (editar motorista, placa, total_faturado e substituir pedidos).
  /// PUT api/romaneios.php — bloqueia se romaneio já estiver concluído.
  Future<void> atualizarRomaneio({
    required int idEmpresa,
    required int idRomaneio,
    required String motoristaEntregador,
    required String placa,
    required double totalFaturado,
    required List<int> pedidosIds,
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    final body = <String, dynamic>{
      'id_empresa': idEmpresa,
      'id_romaneio': idRomaneio,
      'motorista_entregador': motoristaEntregador.trim(),
      'placa': placa.trim(),
      'total_faturado': totalFaturado,
      'pedidos': pedidosIds,
    };

    final response = await _dioClient.put<Map<String, dynamic>>(
      _pathRomaneios,
      data: body,
    );
    _validarRespostaAtualizar(response, allowEmptyResponseOnSuccess);
  }

  void _validarRespostaAtualizar(
    dynamic response,
    bool allowEmptyResponseOnSuccess,
  ) {
    _requireOk(
      response.data as Map<String, dynamic>?,
      defaultMessage: 'Erro ao atualizar romaneio.',
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
      statusCode: response.statusCode,
      invalidMessage: 'Resposta inválida ao atualizar romaneio.',
    );
  }

  /// Arquivar romaneio (soft delete). DELETE api/romaneios.php body: id_empresa, id_romaneio.
  /// [allowEmptyResponseOnSuccess]: se true, 2xx com body null é tratado como sucesso.
  Future<void> arquivarRomaneio({
    required int idEmpresa,
    required int idRomaneio,
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    final response = await _dioClient.delete<Map<String, dynamic>>(
      _pathRomaneios,
      data: <String, dynamic>{
        'id_empresa': idEmpresa,
        'id_romaneio': idRomaneio,
      },
    );
    _requireOk(
      response.data,
      defaultMessage: 'Erro ao arquivar romaneio.',
      allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
      statusCode: response.statusCode,
      invalidMessage: 'Resposta inválida ao arquivar romaneio.',
    );
  }

  /// Cria o romaneio na API.
  /// [totalFaturado]: soma do valor total de todos os pedidos do romaneio.
  /// [placaVeiculo]: placa do veículo (obrigatória se motorista próprio; pode ser vazia para agregado).
  /// [allowEmptyResponseOnSuccess]: se true, 2xx com body null é tratado como sucesso (retorna id 0).
  Future<RomaneioCriarResult> criarRomaneio({
    required int idEmpresa,
    required String motoristaEntregador,
    required List<int> pedidos,
    required double totalFaturado,
    String? placaVeiculo,
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    if (pedidos.isEmpty) {
      throw AppException(message: 'Selecione pelo menos um pedido.');
    }
    final body = <String, dynamic>{
      'id_empresa': idEmpresa,
      'motorista_entregador': motoristaEntregador.trim(),
      'pedidos': pedidos,
      'total_faturado': totalFaturado.toString(),
    };
    final placa = placaVeiculo?.trim();
    if (placa != null && placa.isNotEmpty) {
      body['placa_veiculo'] = placa;
    }
    final response = await _dioClient.post<Map<String, dynamic>>(
      _pathRomaneios,
      data: body,
    );
    final data = response.data;
    if (data == null) {
      if (allowEmptyResponseOnSuccess &&
          ApiConfig.isSuccessStatusCode(response.statusCode)) {
        return const RomaneioCriarResult(idRomaneio: 0, qtdPedidos: 0);
      }
      throw AppException(message: 'Resposta inválida do servidor.');
    }
    if (!ApiResponseParser.isSuccess(data)) {
      throw AppException(
        message: ApiResponseParser.message(data) ?? 'Erro ao criar romaneio.',
      );
    }
    final idRomaneio = data['id_romaneio'];
    final qtdPedidos = data['qtd_pedidos'];
    if (idRomaneio == null || qtdPedidos == null) {
      throw AppException(
        message: ApiResponseParser.message(data) ?? 'Erro ao criar romaneio.',
      );
    }
    return RomaneioCriarResult(
      idRomaneio: idRomaneio is int ? idRomaneio : int.tryParse(idRomaneio.toString()) ?? 0,
      qtdPedidos: qtdPedidos is int ? qtdPedidos : int.tryParse(qtdPedidos.toString()) ?? 0,
    );
  }

  void _requireOk(
    Map<String, dynamic>? data, {
    required String defaultMessage,
    required String invalidMessage,
    bool allowEmptyResponseOnSuccess = false,
    int? statusCode,
  }) {
    try {
      ApiResponseParser.requireOk(
        data,
        defaultMessage: defaultMessage,
        allowEmptyResponseOnSuccess: allowEmptyResponseOnSuccess,
        statusCode: statusCode,
      );
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg == 'Resposta inválida da API') {
        throw AppException(message: invalidMessage);
      }
      throw AppException(message: msg);
    }
  }
}
