abstract class AppConstants {
  static const String appName = 'Vendas Base';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://aliancadev.com/estoque_vendas01/';
  static const String brasilApiCnpjBaseUrl =
      'https://brasilapi.com.br/api/cnpj/v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
