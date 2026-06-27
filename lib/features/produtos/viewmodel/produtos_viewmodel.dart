import 'dart:async';

import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import 'package:erp_alianca_dev/shared/utils/list_pagination_helper.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';

class ProdutosViewModel extends BaseViewModel {
  ProdutosViewModel(this._produtoService);

  final ProdutoService _produtoService;
  final ListPaginationHelper _pagination = ListPaginationHelper();
  final ListPaginationHelper _paginationBusca = ListPaginationHelper();

  ViewState _state = ViewState.idle;
  String _errorMessage = '';
  final List<ProdutoModel> _produtosTodos = [];
  final List<ProdutoModel> _produtosBusca = [];
  String _query = '';
  bool _hasSearched = false;
  ViewState _stateBusca = ViewState.idle;
  Timer? _debounceBusca;

  static const Duration _debounceDuration = Duration(milliseconds: 400);

  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  List<ProdutoModel> get produtosTodos => List.unmodifiable(_produtosTodos);
  List<ProdutoModel> get produtosBusca => List.unmodifiable(_produtosBusca);
  String get query => _query;
  bool get hasSearched => _hasSearched;
  ViewState get stateBusca => _stateBusca;
  int get totalProdutos => _pagination.total;
  bool get hasMoreProdutos => _pagination.hasMore;
  bool get isLoadingMoreProdutos => _pagination.isLoadingMore;
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

  Future<void> loadProdutos() async {
    if (isDisposed) return;
    _pagination.reset();
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      final result = await _produtoService.listarPaginado(page: 1);
      if (isDisposed) return;
      _pagination.applyFirstPage(result, _produtosTodos);
      _state = ViewState.success;
    } catch (_) {
      if (isDisposed) return;
      _errorMessage = 'Erro ao carregar produtos. Tente novamente.';
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> loadMoreProdutos() async {
    if (!_pagination.hasMore || _pagination.isLoadingMore) return;
    _pagination.isLoadingMore = true;
    notifyListeners();
    try {
      if (_pagination.loadMoreFromCache(_produtosTodos)) {
        if (isDisposed) return;
        _pagination.isLoadingMore = false;
        notifyListeners();
        return;
      }
      final result = await _produtoService.listarPaginado(
        page: _pagination.page + 1,
      );
      if (isDisposed) return;
      _pagination.applyNextPage(result, _produtosTodos);
    } catch (_) {}
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
      final result = await _produtoService.listarPaginado(page: 1, q: q);
      if (isDisposed) return;
      _paginationBusca.applyFirstPage(result, _produtosBusca);
      _stateBusca = ViewState.success;
    } catch (_) {
      if (isDisposed) return;
      _stateBusca = ViewState.error;
    }
    notifyListeners();
  }

  void resetBusca({bool notify = true}) {
    _debounceBusca?.cancel();
    _debounceBusca = null;
    _query = '';
    _produtosBusca.clear();
    _paginationBusca.reset();
    _hasSearched = false;
    _stateBusca = ViewState.idle;
    if (notify) notifyListeners();
  }

  void limparBusca() => resetBusca();
}
