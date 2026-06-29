abstract class AppConstants {
  static const String appName = 'Vendas Base';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://aliancadev.com/estoque_vendas01/';
  static const String brasilApiCnpjBaseUrl =
      'https://brasilapi.com.br/api/cnpj/v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// WebSocket erp_realtime (Phoenix). Desligado por padrão — não exibe erro ao usuário se indisponível.
  /// Para ativar localmente: `flutter run --dart-define=REALTIME_ENABLED=true`
  static const bool realtimeEnabled = bool.fromEnvironment(
    'REALTIME_ENABLED',
    defaultValue: false,
  );

  /// WebSocket do serviço Elixir (erp_realtime). Dev: WSL em localhost:4000.
  static const String realtimeWsUrl = 'ws://127.0.0.1:4000/socket/websocket';
}
