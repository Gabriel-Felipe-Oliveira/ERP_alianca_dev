/// Credenciais padrão do ambiente de demonstração (`estoque_vendas01`).
/// Usar **somente** em testes — nunca em código de produção.
abstract final class TestAuthCredentials {
  static const String email = 'admin@empresa.com';
  static const String senha = '123456';
  static const String deviceName = 'Flutter Test';
}
