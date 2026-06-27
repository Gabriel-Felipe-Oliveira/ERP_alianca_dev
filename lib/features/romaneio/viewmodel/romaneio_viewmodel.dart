import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';
import 'package:erp_alianca_dev/shared/utils/list_pagination_helper.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';

/// Filtro de status: Em aberto (todos exceto concluído/cancelado), Concluído, Cancelado.
const List<({String value, String label})> kRomaneioStatusFiltros = [
  (value: '', label: 'Em aberto'),
  (value: 'concluido', label: 'Concluído'),
  (value: 'cancelado', label: 'Cancelado'),
];

class RomaneioViewModel extends BaseViewModel {
  RomaneioViewModel(this._romaneioService);

  final RomaneioService _romaneioService;
  final ListPaginationHelper _pagination = ListPaginationHelper();

  ViewState _state = ViewState.idle;
  String _errorMessage = '';
  final List<RomaneioModel> _romaneios = [];
  String _statusFiltro = '';
  bool _includeDeleted = false;

  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  List<RomaneioModel> get romaneios => List.unmodifiable(_romaneios);
  String get statusFiltro => _statusFiltro;
  bool get includeDeleted => _includeDeleted;
  int get totalRomaneios => _pagination.total;
  bool get hasMoreRomaneios => _pagination.hasMore;
  bool get isLoadingMoreRomaneios => _pagination.isLoadingMore;

  double get totalFaturadoListagem =>
      _romaneios.fold<double>(0, (s, r) => s + r.totalFaturado);

  void setStatusFiltro(String value) {
    if (_statusFiltro == value) return;
    _statusFiltro = value;
    notifyListeners();
  }

  void setIncludeDeleted(bool value) {
    if (_includeDeleted == value) return;
    _includeDeleted = value;
    notifyListeners();
  }

  List<RomaneioModel> _filtrarEmAberto(List<RomaneioModel> lista) {
    if (_statusFiltro.isNotEmpty) return lista;
    return lista
        .where((r) =>
            r.status != RomaneioStatus.concluido &&
            r.status != RomaneioStatus.cancelado)
        .toList();
  }

  Future<void> loadRomaneios() async {
    if (isDisposed) return;
    _pagination.reset();
    _state = ViewState.loading;
    _errorMessage = '';
    _romaneios.clear();
    notifyListeners();

    try {
      final result = await _romaneioService.listarRomaneiosPaginado(
        page: 1,
        status: _statusFiltro.isEmpty ? null : _statusFiltro,
        includeDeleted: _includeDeleted,
      );
      if (isDisposed) return;

      if (_statusFiltro.isEmpty && result.fullCache != null) {
        final filtrados = _filtrarEmAberto(result.fullCache!);
        _pagination.setFullCache(filtrados, _romaneios);
      } else if (_statusFiltro.isEmpty) {
        final filtrados = _filtrarEmAberto(result.items);
        _romaneios.addAll(filtrados);
        _pagination
          ..total = filtrados.length
          ..hasMore = result.hasMore
          ..page = result.page;
      } else {
        _pagination.applyFirstPage(result, _romaneios);
      }
      _state = ViewState.success;
    } on AppException catch (e) {
      if (isDisposed) return;
      _errorMessage = e.message;
      _state = ViewState.error;
    } catch (e) {
      if (isDisposed) return;
      _errorMessage = BaseViewModel.userMessage(
        e,
        'Erro ao carregar romaneios. Tente novamente.',
      );
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> loadMoreRomaneios() async {
    if (!_pagination.hasMore || _pagination.isLoadingMore) return;
    _pagination.isLoadingMore = true;
    notifyListeners();
    try {
      if (_pagination.loadMoreFromCache(_romaneios)) {
        if (isDisposed) return;
        _pagination.isLoadingMore = false;
        notifyListeners();
        return;
      }
      final result = await _romaneioService.listarRomaneiosPaginado(
        page: _pagination.page + 1,
        status: _statusFiltro.isEmpty ? null : _statusFiltro,
        includeDeleted: _includeDeleted,
      );
      if (isDisposed) return;
      final novos = _statusFiltro.isEmpty
          ? _filtrarEmAberto(result.items)
          : result.items;
      _romaneios.addAll(novos);
      _pagination
        ..page = result.page
        ..hasMore = result.hasMore
        ..total = result.total;
    } catch (e) {
      BaseViewModel.logFailure(e, tag: 'RomaneioViewModel.loadMore');
    }
    _pagination.isLoadingMore = false;
    notifyListeners();
  }
}
