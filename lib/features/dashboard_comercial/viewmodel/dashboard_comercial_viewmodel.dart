import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/model/dashboard_comercial_model.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/utils/dashboard_comercial_formatters.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/dashboard_service.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';

class DashboardComercialViewModel extends BaseViewModel {
  DashboardComercialViewModel(this._dashboardService) {
    final hoje = DateTime.now();
    final inicioMes = DateTime(hoje.year, hoje.month, 1);
    _dataInicio = inicioMes;
    _dataFim = hoje;
  }

  final DashboardService _dashboardService;

  ViewState _state = ViewState.idle;
  String? _errorMessage;
  DashboardComercialModel _dados = DashboardComercialModel.vazio;

  late DateTime _dataInicio;
  late DateTime _dataFim;
  String _agrupamento = 'diario';
  String _statusPedido = '';
  bool _includeDeleted = false;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  DashboardComercialModel get dados => _dados;
  DateTime get dataInicio => _dataInicio;
  DateTime get dataFim => _dataFim;
  String get agrupamento => _agrupamento;
  String get statusPedido => _statusPedido;
  bool get includeDeleted => _includeDeleted;
  bool get isLoading => _state == ViewState.loading;

  DashboardComercialFiltros get filtrosAtuais => DashboardComercialFiltros(
        dataInicio: formatarDataApi(_dataInicio),
        dataFim: formatarDataApi(_dataFim),
        agrupamento: _agrupamento,
        statusPedido: _statusPedido.isEmpty ? null : _statusPedido,
        includeDeleted: _includeDeleted,
      );

  void setDataInicio(DateTime value) {
    if (_sameDay(_dataInicio, value)) return;
    _dataInicio = value;
    if (_dataFim.isBefore(_dataInicio)) {
      _dataFim = _dataInicio;
    }
    notifyListeners();
  }

  void setDataFim(DateTime value) {
    if (_sameDay(_dataFim, value)) return;
    _dataFim = value;
    if (_dataInicio.isAfter(_dataFim)) {
      _dataInicio = _dataFim;
    }
    notifyListeners();
  }

  void setAgrupamento(String value) {
    if (_agrupamento == value) return;
    _agrupamento = value;
    notifyListeners();
  }

  void setStatusPedido(String value) {
    if (_statusPedido == value) return;
    _statusPedido = value;
    notifyListeners();
  }

  void setIncludeDeleted(bool value) {
    if (_includeDeleted == value) return;
    _includeDeleted = value;
    notifyListeners();
  }

  Future<void> carregar() async {
    if (isDisposed) return;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _dashboardService.buscarComercial(filtrosAtuais);
      if (isDisposed) return;
      _dados = result;
      _state = ViewState.success;
    } catch (e) {
      if (isDisposed) return;
      final msg = BaseViewModel.readErrorForUi(
        e,
        tag: 'DashboardComercialViewModel',
        fallback: 'Erro ao carregar dashboard comercial.',
      );
      if (msg == null) {
        _dados = DashboardComercialModel.vazio;
        _state = ViewState.success;
      } else {
        _errorMessage = e is AppException ? e.message : msg;
        _state = ViewState.error;
      }
    }
    notifyListeners();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
