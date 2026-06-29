import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/models/dashboard_totais_model.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/dashboard_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/utils/list_pagination_helper.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';

/// Filtro de status: Em aberto = apenas confirmados; Organizado; Concluído; Cancelado.
const List<({String value, String label})> kPedidoStatusFiltros = [
  (value: '', label: 'Em aberto'),
  (value: 'organizado', label: 'Organizado'),
  (value: 'concluido', label: 'Concluído'),
  (value: 'cancelado', label: 'Cancelado'),
];

class PedidosViewModel extends BaseViewModel {
  PedidosViewModel(
    this._pedidoService,
    this._clienteService,
    this._dashboardService,
  );

  final PedidoService _pedidoService;
  final ClienteService _clienteService;
  final DashboardService _dashboardService;
  final ListPaginationHelper _pagination = ListPaginationHelper();

  ViewState _state = ViewState.idle;
  String _errorMessage = '';
  final List<PedidoListagemModel> _pedidos = [];
  final Map<int, String> _nomesClientes = {};
  String _statusFiltro = '';
  double _totalGeralListagem = 0;

  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  List<PedidoListagemModel> get pedidos => List.unmodifiable(_pedidos);
  String get statusFiltro => _statusFiltro;
  int get totalPedidos => _pagination.total;
  bool get hasMorePedidos => _pagination.hasMore;
  bool get isLoadingMorePedidos => _pagination.isLoadingMore;

  double get totalGeralListagem => _totalGeralListagem;

  void setStatusFiltro(String value) {
    if (_statusFiltro == value) return;
    _statusFiltro = value;
    notifyListeners();
  }

  String nomeCliente(int idCliente) => _nomesClientes[idCliente] ?? '—';

  Future<void> _resolverNomesClientes(Set<int> idsCliente) async {
    final pendentes = idsCliente
        .where((id) => id > 0 && !_nomesClientes.containsKey(id))
        .toList();
    if (pendentes.isEmpty) return;

    await Future.wait(
      pendentes.map((id) async {
        try {
          final cliente = await _clienteService.buscarClientePorId(id);
          if (isDisposed) return;
          _nomesClientes[id] = cliente.nome;
        } on AppException catch (_) {
          if (isDisposed) return;
          _nomesClientes[id] = '—';
        } catch (e) {
          if (isDisposed) return;
          BaseViewModel.logFailure(e, tag: 'PedidosViewModel.nomeCliente');
          _nomesClientes[id] = '—';
        }
      }),
    );
  }

  String get _statusParaApi =>
      _statusFiltro.isEmpty ? 'confirmado' : _statusFiltro;

  Future<void> _carregarTotais() async {
    try {
      final totais = await _dashboardService.buscarTotais(
        DashboardTotaisFiltros(status: _statusParaApi),
      );
      if (isDisposed) return;
      _totalGeralListagem = totais.pedidos.resumo.valorTotal;
    } catch (e) {
      BaseViewModel.logFailure(e, tag: 'PedidosViewModel.totais');
      if (isDisposed) return;
      _totalGeralListagem = 0;
    }
  }

  Future<void> loadPedidos() async {
    if (isDisposed) return;
    _pagination.reset();
    _state = ViewState.loading;
    _errorMessage = '';
    _pedidos.clear();
    _nomesClientes.clear();
    _totalGeralListagem = 0;
    notifyListeners();

    try {
      final result = await _pedidoService.listarPedidosPaginado(
        page: 1,
        status: _statusParaApi,
      );
      if (isDisposed) return;
      _pagination.applyFirstPage(result, _pedidos);

      final idsCliente = _pedidos
          .map((p) => p.idCliente)
          .where((id) => id > 0)
          .toSet();
      await Future.wait([
        _resolverNomesClientes(idsCliente),
        _carregarTotais(),
      ]);

      _state = ViewState.success;
    } catch (e) {
      if (isDisposed) return;
      final msg = BaseViewModel.readErrorForUi(
        e,
        tag: 'PedidosViewModel',
        fallback: 'Erro ao carregar pedidos. Tente novamente.',
      );
      if (msg == null) {
        _pedidos.clear();
        _nomesClientes.clear();
        _pagination.reset();
        _state = ViewState.success;
      } else {
        _errorMessage = msg;
        _state = ViewState.error;
      }
    }
    notifyListeners();
  }

  Future<void> loadMorePedidos() async {
    if (!_pagination.hasMore || _pagination.isLoadingMore) return;
    _pagination.isLoadingMore = true;
    notifyListeners();
    try {
      if (_pagination.loadMoreFromCache(_pedidos)) {
        if (isDisposed) return;
        final idsCliente = _pedidos
            .map((p) => p.idCliente)
            .where((id) => id > 0)
            .toSet();
        await _resolverNomesClientes(idsCliente);
        _pagination.isLoadingMore = false;
        notifyListeners();
        return;
      }
      final result = await _pedidoService.listarPedidosPaginado(
        page: _pagination.page + 1,
        status: _statusParaApi,
      );
      if (isDisposed) return;
      _pagination.applyNextPage(result, _pedidos);
      final idsCliente = result.items
          .map((p) => p.idCliente)
          .where((id) => id > 0)
          .toSet();
      await _resolverNomesClientes(idsCliente);
    } catch (e) {
      BaseViewModel.logFailure(e, tag: 'PedidosViewModel.loadMore');
    }
    _pagination.isLoadingMore = false;
    notifyListeners();
  }
}
