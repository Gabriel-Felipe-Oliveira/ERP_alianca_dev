/// Nome de arquivo para PDF de recibo de pedido (ex.: recibo_00005_Joao_Silva.pdf).
String nomeArquivoReciboPedido(int idPedido, String nomeCliente) {
  final numero = idPedido.toString().padLeft(5, '0');
  final nome = nomeCliente
      .replaceAll(RegExp(r'[/\\:*?"<>|]'), '')
      .replaceAll(RegExp(r'\s+'), '_')
      .trim();
  return nome.isEmpty ? 'recibo_$numero.pdf' : 'recibo_${numero}_$nome.pdf';
}
