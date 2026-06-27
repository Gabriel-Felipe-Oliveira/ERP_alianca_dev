import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/models/cnpj_consulta_model.dart';
import 'package:erp_alianca_dev/shared/services/cnpj_consulta_service.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';

class ClienteConsultaCnpjViewModel extends BaseViewModel {
  ClienteConsultaCnpjViewModel(this._cnpjConsultaService) {
    cnpjController.addListener(notifyListeners);
  }

  final CnpjConsultaService _cnpjConsultaService;

  final TextEditingController cnpjController = TextEditingController();

  ViewState _state = ViewState.idle;
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  String get cnpjDigits =>
      cnpjController.text.replaceAll(RegExp(r'\D'), '');

  bool get podeConsultar =>
      cnpjDigits.length == 14 && _state != ViewState.loading;

  Future<CnpjConsultaModel?> consultar() async {
    if (!podeConsultar) return null;

    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final dados = await _cnpjConsultaService.consultar(cnpjDigits);
      _state = ViewState.success;
      notifyListeners();
      return dados;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
      notifyListeners();
      return null;
    } catch (_) {
      _errorMessage = 'Não foi possível consultar o CNPJ. Tente novamente.';
      _state = ViewState.error;
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    cnpjController.removeListener(notifyListeners);
    cnpjController.dispose();
    super.dispose();
  }
}
