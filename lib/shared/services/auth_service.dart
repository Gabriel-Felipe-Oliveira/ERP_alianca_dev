import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:erp_alianca_dev/core/constants/app_constants.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/features/login/model/auth_session_model.dart';
import 'package:erp_alianca_dev/features/login/model/usuario_model.dart';
import 'package:erp_alianca_dev/features/login/utils/user_perfil.dart';
import 'package:erp_alianca_dev/shared/services/auth_storage_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/local_storage_service.dart';

class AuthService extends ChangeNotifier {
  AuthService({
    required AuthStorageService authStorage,
    required EmpresaService empresaService,
    required LocalStorageService localStorageService,
    Dio? authDio,
  })  : _authStorage = authStorage,
        _empresaService = empresaService,
        _localStorageService = localStorageService,
        _authDio = authDio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.baseUrl,
                connectTimeout: AppConstants.connectionTimeout,
                receiveTimeout: AppConstants.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  final AuthStorageService _authStorage;
  final EmpresaService _empresaService;
  final LocalStorageService _localStorageService;
  final Dio _authDio;

  AuthSessionModel? _session;
  Future<bool>? _refreshInProgress;

  AuthSessionModel? get session => _session;
  UsuarioModel? get usuario => _session?.usuario;
  String? get accessToken => _session?.accessToken;

  /// Dashboard comercial visível só para admin e gerente.
  bool get podeVerDashboardComercial =>
      UserPerfil.podeVerDashboardComercial(usuario?.perfil);

  bool get isAuthenticated {
    final current = _session;
    if (current == null) return false;
    if (!current.isAccessTokenExpired) return true;
    return !current.isRefreshTokenExpired;
  }

  static String get deviceName {
    if (kIsWeb) return 'Flutter Web';
    if (Platform.isWindows) return 'Flutter Windows';
    if (Platform.isAndroid) return 'Flutter Android';
    if (Platform.isIOS) return 'Flutter iOS';
    if (Platform.isMacOS) return 'Flutter macOS';
    if (Platform.isLinux) return 'Flutter Linux';
    return 'Flutter App';
  }

  Future<void> restoreSession() async {
    _session = _authStorage.loadSession();
    if (_session == null) return;

    if (_session!.isAccessTokenExpired && !_session!.isRefreshTokenExpired) {
      final ok = await tryRefreshAccessToken();
      if (!ok) {
        await logoutLocal();
        return;
      }
    } else if (_session!.isRefreshTokenExpired) {
      await logoutLocal();
      return;
    }

    await _empresaService.setEmpresa(
      _session!.empresa,
      _localStorageService,
    );
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await _authDio.post<Map<String, dynamic>>(
        'api/login.php',
        data: {
          'email': email.trim(),
          'senha': senha,
          'device_name': deviceName,
        },
      );
      final data = response.data;
      if (data == null || data['ok'] != true) {
        throw AppException(
          message: _messageFromBody(data) ?? 'Não foi possível fazer login.',
        );
      }

      _session = AuthSessionModel.fromLoginJson(data, deviceName: deviceName);
      await _authStorage.saveSession(_session!);
      await _empresaService.setEmpresa(
        _session!.empresa,
        _localStorageService,
      );
      notifyListeners();
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<bool> tryRefreshAccessToken() async {
    if (_refreshInProgress != null) {
      return _refreshInProgress!;
    }
    _refreshInProgress = _refreshAccessToken();
    try {
      return await _refreshInProgress!;
    } finally {
      _refreshInProgress = null;
    }
  }

  Future<bool> _refreshAccessToken() async {
    final current = _session;
    if (current == null || current.refreshToken.isEmpty) return false;
    if (current.isRefreshTokenExpired) return false;

    try {
      final response = await _authDio.post<Map<String, dynamic>>(
        'api/sessions.php',
        data: {
          'action': 'refresh',
          'refresh_token': current.refreshToken,
        },
      );
      final data = response.data;
      if (data == null || data['ok'] != true) return false;

      _session = AuthSessionModel.fromRefreshJson(data, current);
      await _authStorage.saveSession(_session!);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final current = _session;
    if (current != null && current.accessToken.isNotEmpty) {
      try {
        await _authDio.patch<Map<String, dynamic>>(
          'api/sessions.php',
          data: {'id_session': current.idSession},
          options: Options(
            headers: {'X-Access-Token': current.accessToken},
          ),
        );
      } catch (_) {
        // Revoga localmente mesmo se a API falhar.
      }
    }
    await logoutLocal();
  }

  Future<void> logoutLocal() async {
    _session = null;
    await _authStorage.clearSession();
    await _empresaService.clearSession(_localStorageService);
    notifyListeners();
  }

  static String? _messageFromBody(Map<String, dynamic>? data) {
    if (data == null) return null;
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) return message.trim();
    return null;
  }

  /// Apenas para testes unitários.
  @visibleForTesting
  void debugSetSession(AuthSessionModel session) {
    _session = session;
  }
}
