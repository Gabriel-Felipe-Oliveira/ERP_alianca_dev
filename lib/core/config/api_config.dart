/// Utilitários para respostas da API.
class ApiConfig {
  ApiConfig._();

  /// Verifica se o status HTTP é sucesso (2xx).
  static bool isSuccessStatusCode(int? code) =>
      code != null && code >= 200 && code < 300;
}
