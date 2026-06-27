import 'dart:convert';

import 'package:erp_alianca_dev/features/login/model/auth_session_model.dart';
import 'package:erp_alianca_dev/shared/services/local_storage_service.dart';

class AuthStorageService {
  AuthStorageService(this._storage);

  final LocalStorageService _storage;

  static const String _sessionKey = 'auth_session_json';

  Future<void> saveSession(AuthSessionModel session) async {
    await _storage.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  AuthSessionModel? loadSession() {
    final raw = _storage.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSessionModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() => _storage.remove(_sessionKey);
}
