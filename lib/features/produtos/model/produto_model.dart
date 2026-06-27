/// Model do produto (criação e resposta da API).
class ProdutoModel {
  final int? idProduto;
  final int idEmpresa;
  final String nome;
  final double preco;
  final int estoqueAtual;
  final String status;

  const ProdutoModel({
    this.idProduto,
    required this.idEmpresa,
    required this.nome,
    required this.preco,
    required this.estoqueAtual,
    required this.status,
  });

  /// Payload para POST criar produto. [preco] já em número (sem máscara de moeda).
  Map<String, dynamic> toJson() {
    return {
      'id_empresa': idEmpresa,
      'nome': nome,
      'preco': preco,
      'estoque_atual': estoqueAtual,
      'status': status,
    };
  }

  /// Resposta 201: { "ok": true, "id_produto": 3 }
  factory ProdutoModel.fromJsonCriar(Map<String, dynamic> json) {
    return ProdutoModel(
      idProduto: json['id_produto'] as int?,
      idEmpresa: json['id_empresa'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      preco: (json['preco'] as num?)?.toDouble() ?? 0,
      estoqueAtual: json['estoque_atual'] as int? ?? 0,
      status: json['status'] as String? ?? 'ativo',
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return (double.tryParse(v.replaceAll(',', '.')) ?? 0);
    return 0;
  }

  /// Listagem/detalhe da API (quando vier objeto completo).
  /// Aceita números como int ou String (ex.: API PHP).
  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      idProduto: _parseInt(json['id_produto']),
      idEmpresa: _parseInt(json['id_empresa']) ?? 0,
      nome: json['nome'] is String ? json['nome'] as String : (json['nome']?.toString() ?? ''),
      preco: _parseDouble(json['preco']),
      estoqueAtual: _parseInt(json['estoque_atual']) ?? 0,
      status: json['status'] is String ? json['status'] as String : 'ativo',
    );
  }
}
