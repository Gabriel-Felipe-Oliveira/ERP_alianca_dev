import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/models/dashboard_totais_model.dart';
import 'package:erp_alianca_dev/shared/services/dashboard_service.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';
import 'package:erp_alianca_dev/shared/utils/list_pagination_helper.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';

/// Filtro de status. Padrão [em_rota]: mesmo status do romaneio ao cadastrar.
const List<({String value, String label})> kRomaneioStatusFiltros = [
  (value: 'em_rota', label: 'Em rota'),
  (value: 'concluido', label: 'Concluído'),
  (value: 'cancelado', label: 'Cancelado'),
];

class RomaneioViewModel extends BaseViewModel {
  RomaneioViewModel(this._romaneioService, this._dashboardService);

  final RomaneioService _romaneioService;
  final DashboardService _dashboardService;
  final ListPaginationHelper _pagination = ListPaginationHelper();

  ViewState _state = ViewState.idle;
  String _errorMessage = '';
  final List<RomaneioModel> _romaneios = [];
  String _statusFiltro = 'em_rota';
  bool _includeDeleted = false;
  double _totalFaturadoListagem = 0;

  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  List<RomaneioModel> get romaneios => List.unmodifiable(_romaneios);
  String get statusFiltro => _statusFiltro;
  bool get includeDeleted => _includeDeleted;
  int get totalRomaneios => _pagination.total;
  bool get hasMoreRomaneios => _pagination.hasMore;
  bool get isLoadingMoreRomaneios => _pagination.isLoadingMore;

  double get totalFaturadoListagem => _totalFaturadoListagem;

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

  Future<void> _carregarTotais() async {
    try {
      final totais = await _dashboardService.buscarTotais(
        DashboardTotaisFiltros(
          status: _statusFiltro,
          includeDeleted: _includeDeleted,
        ),
      );
      if (isDisposed) return;
      _totalFaturadoListagem = totais.romaneios.resumo.valorTotal;
    } catch (e) {
      BaseViewModel.logFailure(e, tag: 'RomaneioViewModel.totais');
      if (isDisposed) return;
      _totalFaturadoListagem = 0;
    }
  }

  Future<void> loadRomaneios() async {
    if (isDisposed) return;
    _pagination.reset();
    _state = ViewState.loading;
    _errorMessage = '';
    _romaneios.clear();
    _totalFaturadoListagem = 0;
    notifyListeners();

    try {
      final result = await _romaneioService.listarRomaneiosPaginado(
        page: 1,
        status: _statusFiltro,
        includeDeleted: _includeDeleted,
      );
      if (isDisposed) return;
      _pagination.applyFirstPage(result, _romaneios);
      await _carregarTotais();
      _state = ViewState.success;
    } catch (e) {
      if (isDisposed) return;
      final msg = BaseViewModel.readErrorForUi(
        e,
        tag: 'RomaneioViewModel',
        fallback: 'Erro ao carregar romaneios. Tente novamente.',
      );
      if (msg == null) {
        _romaneios.clear();
        _pagination.reset();
        _state = ViewState.success;
      } else {
        _errorMessage = msg;
        _state = ViewState.error;
      }
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
        status: _statusFiltro,
        includeDeleted: _includeDeleted,
      );
      if (isDisposed) return;
      _pagination.applyNextPage(result, _romaneios);
    } catch (e) {
      BaseViewModel.logFailure(e, tag: 'RomaneioViewModel.loadMore');
    }
    _pagination.isLoadingMore = false;
    notifyListeners();
  }
}
