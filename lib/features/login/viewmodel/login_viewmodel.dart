import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';

class LoginViewModel extends BaseViewModel {
  LoginViewModel(this._authService) {
    emailController.addListener(notifyListeners);
    senhaController.addListener(notifyListeners);
  }

  final AuthService _authService;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ViewState _state = ViewState.idle;
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  bool get podeEntrar =>
      emailController.text.trim().isNotEmpty &&
      senhaController.text.isNotEmpty &&
      _state != ViewState.loading;

  Future<bool> entrar() async {
    _errorMessage = null;
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    _state = ViewState.loading;
    notifyListeners();

    try {
      await _authService.login(
        email: emailController.text.trim(),
        senha: senhaController.text,
      );
      senhaController.clear();
      _state = ViewState.success;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível fazer login. Tente novamente.';
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    emailController.removeListener(notifyListeners);
    senhaController.removeListener(notifyListeners);
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }
}
