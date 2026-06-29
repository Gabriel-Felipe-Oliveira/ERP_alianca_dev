import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/shared/models/dashboard_totais_model.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/dashboard_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';

import 'mock_dio_client.dart';

DioClient bareTestClient() =>
    DioClient(EmpresaService(), createTestAuthService(EmpresaService()));

class FakePedidoService extends PedidoService {
  FakePedidoService() : super(bareTestClient());

  PaginatedResult<PedidoListagemModel>? resultado;
  AppException? erroAoListar;
  int listarCalls = 0;

  @override
  Future<PaginatedResult<PedidoListagemModel>> listarPedidosPaginado({
    required int page,
    int limit = 20,
    String? status,
    int? idCliente,
  }) async {
    listarCalls++;
    if (erroAoListar != null) throw erroAoListar!;
    return resultado ??
        PaginatedResult(
          items: const [],
          page: page,
          limit: limit,
          total: 0,
          hasMore: false,
        );
  }
}

class FakeDashboardService extends DashboardService {
  FakeDashboardService() : super(bareTestClient());

  DashboardTotaisModel totaisResultado = DashboardTotaisModel.vazio;
  DashboardTotaisFiltros? ultimosFiltrosTotais;
  int buscarTotaisCalls = 0;

  @override
  Future<DashboardTotaisModel> buscarTotais(
    DashboardTotaisFiltros filtros,
  ) async {
    buscarTotaisCalls++;
    ultimosFiltrosTotais = filtros;
    return totaisResultado;
  }
}

class FakeClienteService extends ClienteService {
  FakeClienteService() : super(bareTestClient());

  final Map<int, String> nomes = {};
  PaginatedResult<ClienteModel>? listagemResultado;
  AppException? erroAoListar;

  @override
  Future<PaginatedResult<ClienteModel>> listarClientesPaginado({
    required int page,
    int limit = 20,
    String? status,
    String? q,
    bool includeDeleted = false,
  }) async {
    if (erroAoListar != null) throw erroAoListar!;
    return listagemResultado ??
        PaginatedResult(
          items: const [],
          page: page,
          limit: limit,
          total: 0,
          hasMore: false,
        );
  }

  @override
  Future<ClienteModel> buscarClientePorId(int id) async {
    return ClienteModel(
      id: id,
      nome: nomes[id] ?? 'Cliente $id',
      telefone: '',
      email: '',
      cep: '',
      logradouro: '',
      numero: '',
      bairro: '',
      cidade: '',
      estado: 'MG',
    );
  }
}

class FakeRomaneioService extends RomaneioService {
  FakeRomaneioService() : super(bareTestClient());

  PaginatedResult<RomaneioModel>? resultado;
  AppException? erroAoListar;

  @override
  Future<PaginatedResult<RomaneioModel>> listarRomaneiosPaginado({
    required int page,
    int limit = 20,
    String? status,
    bool includeDeleted = false,
  }) async {
    if (erroAoListar != null) throw erroAoListar!;
    return resultado ??
        PaginatedResult(
          items: const [],
          page: page,
          limit: limit,
          total: 0,
          hasMore: false,
        );
  }
}

class FakeProdutoService extends ProdutoService {
  FakeProdutoService() : super(bareTestClient());

  PaginatedResult<ProdutoModel>? resultado;
  AppException? erroAoListar;
  String? ultimaQuery;
  int listarCalls = 0;

  @override
  Future<PaginatedResult<ProdutoModel>> listarPaginado({
    required int page,
    int limit = 20,
    String? status,
    String? q,
    bool includeDeleted = false,
  }) async {
    listarCalls++;
    ultimaQuery = q;
    if (erroAoListar != null) throw erroAoListar!;
    return resultado ??
        PaginatedResult(
          items: const [],
          page: page,
          limit: limit,
          total: 0,
          hasMore: false,
        );
  }
}
