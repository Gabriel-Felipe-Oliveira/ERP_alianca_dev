import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
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
  PedidosViewModel(this._pedidoService, this._clienteService);

  final PedidoService _pedidoService;
  final ClienteService _clienteService;
  final ListPaginationHelper _pagination = ListPaginationHelper();

  ViewState _state = ViewState.idle;
  String _errorMessage = '';
  final List<PedidoListagemModel> _pedidos = [];
  final Map<int, String> _nomesClientes = {};
  String _statusFiltro = '';

  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  List<PedidoListagemModel> get pedidos => List.unmodifiable(_pedidos);
  String get statusFiltro => _statusFiltro;
  int get totalPedidos => _pagination.total;
  bool get hasMorePedidos => _pagination.hasMore;
  bool get isLoadingMorePedidos => _pagination.isLoadingMore;

  double get totalGeralListagem =>
      _pedidos.fold<double>(0, (s, p) => s + p.total);

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
        } catch (_) {
          if (isDisposed) return;
          _nomesClientes[id] = '—';
        }
      }),
    );
  }

  String get _statusParaApi =>
      _statusFiltro.isEmpty ? 'confirmado' : _statusFiltro;

  Future<void> loadPedidos() async {
    if (isDisposed) return;
    _pagination.reset();
    _state = ViewState.loading;
    _errorMessage = '';
    _pedidos.clear();
    _nomesClientes.clear();
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
      await _resolverNomesClientes(idsCliente);

      _state = ViewState.success;
    } catch (_) {
      if (isDisposed) return;
      _errorMessage = 'Erro ao carregar pedidos. Tente novamente.';
      _state = ViewState.error;
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
    } catch (_) {}
    _pagination.isLoadingMore = false;
    notifyListeners();
  }
}
