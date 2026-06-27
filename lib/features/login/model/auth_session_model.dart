import 'package:erp_alianca_dev/core/security/sensitive_data_sanitizer.dart';
import 'package:erp_alianca_dev/features/login/model/usuario_model.dart';
import 'package:erp_alianca_dev/shared/models/empresa_model.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    this.refreshExpiresAt,
    required this.idSession,
    this.sessionExpiresAt,
    required this.deviceName,
    required this.empresa,
    required this.usuario,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final DateTime? refreshExpiresAt;
  final int idSession;
  final String? sessionExpiresAt;
  final String deviceName;
  final EmpresaModel empresa;
  final UsuarioModel usuario;

  bool get isAccessTokenExpired =>
      DateTime.now().isAfter(accessExpiresAt);

  bool get isRefreshTokenExpired {
    final expires = refreshExpiresAt;
    if (expires == null) return false;
    return DateTime.now().isAfter(expires);
  }

  bool get isValid => !isAccessTokenExpired || !isRefreshTokenExpired;

  AuthSessionModel copyWith({
    String? accessToken,
    DateTime? accessExpiresAt,
    String? sessionExpiresAt,
  }) {
    return AuthSessionModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken,
      accessExpiresAt: accessExpiresAt ?? this.accessExpiresAt,
      refreshExpiresAt: refreshExpiresAt,
      idSession: idSession,
      sessionExpiresAt: sessionExpiresAt ?? this.sessionExpiresAt,
      deviceName: deviceName,
      empresa: empresa,
      usuario: usuario,
    );
  }

  factory AuthSessionModel.fromLoginJson(
    Map<String, dynamic> json, {
    required String deviceName,
  }) {
    final session = json['session'] as Map<String, dynamic>? ?? {};
    final expiresIn = json['expires_in'] as int? ?? 3600;
    final refreshExpiresIn = json['refresh_expires_in'] as int?;

    return AuthSessionModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      accessExpiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      refreshExpiresAt: refreshExpiresIn != null
          ? DateTime.now().add(Duration(seconds: refreshExpiresIn))
          : null,
      idSession: session['id_session'] as int? ?? 0,
      sessionExpiresAt: session['expires_at'] as String?,
      deviceName: session['device_name'] as String? ?? deviceName,
      empresa: EmpresaModel.fromLoginJson(
        json['empresa'] as Map<String, dynamic>? ?? {},
      ),
      usuario: UsuarioModel.fromJson(
        json['usuario'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory AuthSessionModel.fromRefreshJson(
    Map<String, dynamic> json,
    AuthSessionModel current,
  ) {
    final session = json['session'] as Map<String, dynamic>? ?? {};
    final expiresIn = json['expires_in'] as int? ?? 3600;

    return current.copyWith(
      accessToken: json['access_token'] as String? ?? current.accessToken,
      accessExpiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      sessionExpiresAt: session['expires_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'access_expires_at': accessExpiresAt.toIso8601String(),
        'refresh_expires_at': refreshExpiresAt?.toIso8601String(),
        'id_session': idSession,
        'session_expires_at': sessionExpiresAt,
        'device_name': deviceName,
        'empresa': {
          'id_empresa': empresa.idEmpresa,
          'razao_social': empresa.razaoSocial,
          'nome_fantasia': empresa.nomeFantasia,
          'status': empresa.status,
        },
        'usuario': usuario.toJson(),
      };

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final empresaJson = json['empresa'] as Map<String, dynamic>? ?? {};
    return AuthSessionModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      accessExpiresAt: DateTime.parse(
        json['access_expires_at'] as String,
      ),
      refreshExpiresAt: json['refresh_expires_at'] != null
          ? DateTime.parse(json['refresh_expires_at'] as String)
          : null,
      idSession: json['id_session'] as int? ?? 0,
      sessionExpiresAt: json['session_expires_at'] as String?,
      deviceName: json['device_name'] as String? ?? '',
      empresa: EmpresaModel.fromLoginJson(empresaJson),
      usuario: UsuarioModel.fromJson(
        json['usuario'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  @override
  String toString() =>
      'AuthSessionModel(idSession: $idSession, '
      'accessToken: ${SensitiveDataSanitizer.redact(accessToken)}, '
      'refreshToken: ${SensitiveDataSanitizer.redact(refreshToken)}, '
      'usuario: ${usuario.email})';
}
