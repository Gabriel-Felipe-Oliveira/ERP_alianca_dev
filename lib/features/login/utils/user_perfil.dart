/// Perfis retornados pela API no login (`usuario.perfil`).
abstract final class UserPerfil {
  static const String admin = 'admin';
  static const String gerente = 'gerente';
  static const String operador = 'operador';

  /// Dashboard comercial: apenas admin e gerente.
  static bool podeVerDashboardComercial(String? perfil) {
    final normalized = perfil?.trim().toLowerCase() ?? '';
    return normalized == admin || normalized == gerente;
  }

  /// Perfil administrador (somente `admin`).
  static bool isAdmin(String? perfil) {
    return perfil?.trim().toLowerCase() == admin;
  }
}
