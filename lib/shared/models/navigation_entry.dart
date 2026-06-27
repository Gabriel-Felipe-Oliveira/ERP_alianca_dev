/// Entrada no histórico de navegação.
///
/// Guarda a rota (path) e dados extras opcionais (ex.: ID de cliente).
/// Usado pelo [NavigationController] para manter o histórico sem stack.
///
/// Exemplo:
/// ```dart
/// NavigationEntry(
///   rota: '/clientes/detalhe',
///   dados: {'idCliente': 42, 'nomeCliente': 'João'},
/// )
/// ```
class NavigationEntry {
  /// Caminho da rota (ex.: '/clientes/criar').
  final String rota;

  /// Dados extras associados à rota (ex.: ID de um cliente).
  /// Pode ser qualquer Map de String para Object?.
  final Map<String, Object?> dados;

  const NavigationEntry({
    required this.rota,
    this.dados = const {},
  });

  /// Verifica se a rota é igual (ignora dados — usado para evitar duplicação).
  bool mesmaRota(NavigationEntry outro) => rota == outro.rota;

  /// Recupera um dado tipado pelo nome da chave.
  /// Retorna null se não existir ou se o tipo não bater.
  T? obterDado<T>(String chave) {
    final valor = dados[chave];
    return valor is T ? valor : null;
  }

  @override
  String toString() => 'NavigationEntry(rota: $rota, dados: $dados)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationEntry &&
          runtimeType == other.runtimeType &&
          rota == other.rota;

  @override
  int get hashCode => rota.hashCode;
}
