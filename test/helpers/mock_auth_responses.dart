/// Respostas mock da API de autenticação para testes unitários.
abstract final class MockAuthResponses {
  static const accessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.access-secret';
  static const refreshToken = 'refresh-secret-token-xyz';
  static const newAccessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.new-access';

  static Map<String, dynamic> loginSuccess({
    int idSession = 42,
    int idEmpresa = 1,
  }) =>
      {
        'ok': true,
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': 'Bearer',
        'expires_in': 3600,
        'refresh_expires_in': 86400,
        'session': {
          'id_session': idSession,
          'expires_at': '2026-07-26 20:30:00',
          'device_name': 'Flutter Test',
        },
        'empresa': {
          'id_empresa': idEmpresa,
          'razao_social': 'Empresa Teste LTDA',
          'nome_fantasia': 'Empresa Teste',
          'status': 'ativa',
        },
        'usuario': {
          'id_usuario': 4,
          'id_empresa': idEmpresa,
          'nome': 'Administrador',
          'email': 'admin@empresa.com',
          'telefone': '',
          'perfil': 'admin',
          'status': 'ativo',
        },
      };

  static Map<String, dynamic> loginFailure({String message = 'Credenciais inválidas'}) =>
      {
        'ok': false,
        'message': message,
      };

  static Map<String, dynamic> refreshSuccess({int idSession = 42}) => {
        'ok': true,
        'access_token': newAccessToken,
        'token_type': 'Bearer',
        'expires_in': 3600,
        'session': {
          'id_session': idSession,
          'expires_at': '2026-07-27 20:30:00',
        },
      };

  static Map<String, dynamic> logoutSuccess() => {
        'ok': true,
        'rows_affected': 1,
      };
}
