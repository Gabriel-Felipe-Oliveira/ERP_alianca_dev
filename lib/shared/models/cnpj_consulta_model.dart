import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';

/// Dados de empresa retornados pela consulta pública de CNPJ (Receita Federal).
class CnpjConsultaModel {
  const CnpjConsultaModel({
    required this.cnpj,
    required this.razaoSocial,
    this.nomeFantasia,
    this.situacaoCadastral = '',
    this.telefone = '',
    this.email = '',
    this.cep = '',
    this.logradouro = '',
    this.numero = '',
    this.complemento = '',
    this.bairro = '',
    this.cidade = '',
    this.estado = '',
  });

  final String cnpj;
  final String razaoSocial;
  final String? nomeFantasia;
  final String situacaoCadastral;
  final String telefone;
  final String email;
  final String cep;
  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String estado;

  String get cnpjFormatado =>
      ClienteModel.formatarDocumentoParaExibicao('cnpj', cnpj) ?? cnpj;

  String get nomeExibicao {
    final fantasia = nomeFantasia?.trim();
    if (fantasia != null && fantasia.isNotEmpty) return fantasia;
    return razaoSocial;
  }

  factory CnpjConsultaModel.fromBrasilApiJson(Map<String, dynamic> json) {
    final ddd = json['ddd_telefone_1']?.toString().trim() ?? '';
    final tel = json['telefone_1']?.toString().trim() ?? '';
    final telefone = _montarTelefone(ddd, tel);

    return CnpjConsultaModel(
      cnpj: json['cnpj']?.toString().replaceAll(RegExp(r'\D'), '') ?? '',
      razaoSocial: json['razao_social']?.toString().trim() ?? '',
      nomeFantasia: json['nome_fantasia']?.toString().trim(),
      situacaoCadastral:
          json['descricao_situacao_cadastral']?.toString().trim() ?? '',
      telefone: telefone,
      email: json['email']?.toString().trim() ?? '',
      cep: json['cep']?.toString().replaceAll(RegExp(r'\D'), '') ?? '',
      logradouro: json['logradouro']?.toString().trim() ?? '',
      numero: json['numero']?.toString().trim() ?? '',
      complemento: json['complemento']?.toString().trim() ?? '',
      bairro: json['bairro']?.toString().trim() ?? '',
      cidade: json['municipio']?.toString().trim() ?? '',
      estado: json['uf']?.toString().trim() ?? '',
    );
  }

  static String _montarTelefone(String ddd, String numero) {
    if (ddd.isEmpty && numero.isEmpty) return '';
    if (ddd.isEmpty) return numero;
    if (numero.isEmpty) return ddd;
    return '$ddd$numero';
  }

  /// Converte os dados da Receita em [ClienteModel] para cadastro ou pedido.
  ClienteModel toClienteModel({required int idEmpresa}) {
    return ClienteModel(
      idEmpresa: idEmpresa,
      tipoDocumento: 'cnpj',
      documento: cnpj,
      nome: razaoSocial,
      nomeEmpresa: nomeFantasia,
      telefone: telefone,
      email: email,
      cep: cep,
      logradouro: logradouro,
      numero: numero,
      bairro: bairro,
      cidade: cidade,
      estado: estado,
      status: 'Ativo',
    );
  }
}
