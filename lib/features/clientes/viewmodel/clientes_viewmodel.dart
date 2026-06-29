import 'dart:async';

import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/utils/list_pagination_helper.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';

class ClientesViewModel extends BaseViewModel {
  ClientesViewModel(this._clienteService);

  final ClienteService _clienteService;
  final ListPaginationHelper _pagination = ListPaginationHelper();
  final ListPaginationHelper _paginationBusca = ListPaginationHelper();

  ViewState _state = ViewState.idle;
  String _errorMessage = '';
  final List<ClienteModel> _clientesTodos = [];
  final List<ClienteModel> _clientesBusca = [];
  String _query = '';
  bool _hasSearched = false;
  ViewState _stateBusca = ViewState.idle;
  Timer? _debounceBusca;
  String _selectedFilter = 'ativo';

  static const Duration _debounceDuration = Duration(milliseconds: 400);

  static const String filterAtivo = 'ativo';
  static const String filterInativo = 'inativo';
  static const String filterDeletado = 'deletado';

  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  List<ClienteModel> get clientesTodos => List.unmodifiable(_clientesTodos);
  List<ClienteModel> get clientesBusca => List.unmodifiable(_clientesBusca);
  String get query => _query;
  bool get hasSearched => _hasSearched;
  ViewState get stateBusca => _stateBusca;
  String get selectedFilter => _selectedFilter;
  int get totalClientes => _pagination.total;
  bool get hasMoreClientes => _pagination.hasMore;
  bool get isLoadingMoreClientes => _pagination.isLoadingMore;
  int get totalBusca => _paginationBusca.total;
  bool get hasMoreBusca => _paginationBusca.hasMore;
  bool get isLoadingMoreBusca => _paginationBusca.isLoadingMore;

  set query(String value) {
    if (_query == value) return;
    _query = value;
    _debounceBusca?.cancel();
    _debounceBusca = Timer(_debounceDuration, () {
      _debounceBusca = null;
      buscarPorNome();
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceBusca?.cancel();
    super.dispose();
  }

  void _setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> setFilter(String filter) async {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
    await loadClientes();
  }

  ({String status, bool includeDeleted}) get _apiParams {
    switch (_selectedFilter) {
      case filterInativo:
        return (status: 'inativa', includeDeleted: false);
      case filterDeletado:
        return (status: 'inativa', includeDeleted: true);
      case filterAtivo:
      default:
        return (status: 'ativa', includeDeleted: false);
    }
  }

  Future<void> loadClientes() async {
    _pagination.reset();
    _setState(ViewState.loading);
    _errorMessage = '';
    try {
      final params = _apiParams;
      final result = await _clienteService.listarClientesPaginado(
        page: 1,
        status: params.status,
        includeDeleted: params.includeDeleted,
      );
      if (isDisposed) return;
      _pagination.applyFirstPage(result, _clientesTodos);
      _setState(ViewState.success);
    } catch (e) {
      if (isDisposed) return;
      final msg = BaseViewModel.readErrorForUi(
        e,
        tag: 'ClientesViewModel',
        fallback: 'Erro ao carregar clientes. Tente novamente.',
      );
      if (msg == null) {
        _clientesTodos.clear();
        _pagination.reset();
        _setState(ViewState.success);
        return;
      }
      _errorMessage = msg;
      _setState(ViewState.error);
    }
  }

  Future<void> loadMoreClientes() async {
    if (!_pagination.hasMore || _pagination.isLoadingMore) return;
    _pagination.isLoadingMore = true;
    notifyListeners();
    try {
      if (_pagination.loadMoreFromCache(_clientesTodos)) {
        if (isDisposed) return;
        _pagination.isLoadingMore = false;
        notifyListeners();
        return;
      }
      final params = _apiParams;
      final result = await _clienteService.listarClientesPaginado(
        page: _pagination.page + 1,
        status: params.status,
        includeDeleted: params.includeDeleted,
      );
      if (isDisposed) return;
      _pagination.applyNextPage(result, _clientesTodos);
    } catch (e) {
      BaseViewModel.logFailure(e, tag: 'ClientesViewModel.loadMore');
    }
    _pagination.isLoadingMore = false;
    notifyListeners();
  }

  Future<void> buscarPorNome() async {
    if (isDisposed) return;
    _debounceBusca?.cancel();
    _debounceBusca = null;
    _hasSearched = true;
    _paginationBusca.reset();
    _stateBusca = ViewState.loading;
    notifyListeners();
    try {
      final q = _query.trim().isEmpty ? null : _query.trim();
      final params = _apiParams;
      final result = await _clienteService.listarClientesPaginado(
        page: 1,
        status: params.status,
        q: q,
        includeDeleted: params.includeDeleted,
      );
      if (isDisposed) return;
      _paginationBusca.applyFirstPage(result, _clientesBusca);
      _stateBusca = ViewState.success;
    } catch (e) {
      if (isDisposed) return;
      if (BaseViewModel.isSilentNotFound(e)) {
        BaseViewModel.logFailure(e, tag: 'ClientesViewModel.buscar');
        _clientesBusca.clear();
        _paginationBusca.reset();
        _stateBusca = ViewState.success;
      } else {
        BaseViewModel.logFailure(e, tag: 'ClientesViewModel.buscar');
        _stateBusca = ViewState.error;
      }
    }
    notifyListeners();
  }

  Future<void> loadMoreBusca() async {
    if (!_paginationBusca.hasMore || _paginationBusca.isLoadingMore) return;
    _paginationBusca.isLoadingMore = true;
    notifyListeners();
    try {
      if (_paginationBusca.loadMoreFromCache(_clientesBusca)) {
        if (isDisposed) return;
        _paginationBusca.isLoadingMore = false;
        notifyListeners();
        return;
      }
      final q = _query.trim().isEmpty ? null : _query.trim();
      final params = _apiParams;
      final result = await _clienteService.listarClientesPaginado(
        page: _paginationBusca.page + 1,
        status: params.status,
        q: q,
        includeDeleted: params.includeDeleted,
      );
      if (isDisposed) return;
      _paginationBusca.applyNextPage(result, _clientesBusca);
    } catch (e) {
      BaseViewModel.logFailure(e, tag: 'ClientesViewModel.loadMoreBusca');
    }
    _paginationBusca.isLoadingMore = false;
    notifyListeners();
  }

  void resetBusca({bool notify = true}) {
    _debounceBusca?.cancel();
    _debounceBusca = null;
    _query = '';
    _clientesBusca.clear();
    _paginationBusca.reset();
    _hasSearched = false;
    _stateBusca = ViewState.idle;
    if (notify) notifyListeners();
  }

  void limparBusca() => resetBusca();

  Future<void> carregarTodosParaSelecao() async {
    if (isDisposed) return;
    _hasSearched = true;
    _stateBusca = ViewState.loading;
    notifyListeners();
    try {
      _clientesBusca.clear();
      _clientesBusca.addAll(
        await _clienteService.listarClientes(
          status: 'ativa',
          includeDeleted: false,
        ),
      );
      if (isDisposed) return;
      _stateBusca = ViewState.success;
    } catch (e) {
      if (isDisposed) return;
      if (BaseViewModel.isSilentNotFound(e)) {
        BaseViewModel.logFailure(e, tag: 'ClientesViewModel.carregarSelecao');
        _clientesBusca.clear();
        _stateBusca = ViewState.success;
      } else {
        BaseViewModel.logFailure(e, tag: 'ClientesViewModel.carregarSelecao');
        _stateBusca = ViewState.error;
      }
    }
    notifyListeners();
  }
}
