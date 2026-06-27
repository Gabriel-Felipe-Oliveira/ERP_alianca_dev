/// Opções de forma de pagamento (criar pedido e editar em detalhes).
abstract final class FormaPagamentoPedido {
  FormaPagamentoPedido._();

  /// Primeiro item = vazio (UI mostra [labelOpcaoVazia]).
  static const List<String> valoresInternos = <String>[
    '',
    'pix',
    'dinheiro',
    'cartão de crédito',
  ];

  static const String labelOpcaoVazia = '---';

  static bool internoValido(String interno) => interno.trim().isNotEmpty;

  /// Converte resposta da API para valor interno do dropdown.
  static String internoDeApi(String? api) {
    if (api == null || api.trim().isEmpty) return '';
    final n = api.trim().toLowerCase();
    if (n == 'pix') return 'pix';
    if (n == 'dinheiro') return 'dinheiro';
    if (n == 'cartão de crédito' || n == 'cartao de credito') {
      return 'cartão de crédito';
    }
    return '';
  }

  /// Valor enviado ao backend (POST/PATCH).
  static String paraApi(String interno) {
    switch (interno.trim().toLowerCase()) {
      case 'pix':
        return 'Pix';
      case 'dinheiro':
        return 'Dinheiro';
      case 'cartão de crédito':
        return 'Cartão de Crédito';
      default:
        return interno.trim();
    }
  }

  /// Compara textos de pagamento vindos da API (ignora caixa e espaços).
  static bool mesmoPagamentoApi(String? a, String? b) {
    final x = (a ?? '').trim().toLowerCase();
    final y = (b ?? '').trim().toLowerCase();
    return x == y;
  }
}
