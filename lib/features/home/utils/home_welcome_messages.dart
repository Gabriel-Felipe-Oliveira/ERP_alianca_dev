/// Textos e helpers do cabeçalho de boas-vindas da Home.
abstract final class HomeWelcomeMessages {
  static const String subtitle =
      'Escolha um atalho para navegar pelo sistema.';

  static String greeting(String? nomeCompleto) {
    final nome = primeiroNome(nomeCompleto);
    return 'Olá, $nome!';
  }

  static String primeiroNome(String? nomeCompleto) {
    final trimmed = nomeCompleto?.trim();
    if (trimmed == null || trimmed.isEmpty) return 'usuário';
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
