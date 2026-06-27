/// Model de dados da empresa (mock no app; id exposto apenas no Dio).
class EmpresaModel {
  final int idEmpresa;
  final String razaoSocial;
  final String nomeFantasia;
  final String cnpj;
  final String email;
  final String telefone;
  final String cep;
  final String logradouro;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final String status;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  const EmpresaModel({
    required this.idEmpresa,
    required this.razaoSocial,
    required this.nomeFantasia,
    required this.cnpj,
    required this.email,
    required this.telefone,
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.status,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory EmpresaModel.fromJson(Map<String, dynamic> json) {
    return EmpresaModel(
      idEmpresa: json['id_empresa'] as int? ?? 0,
      razaoSocial: json['razao_social'] as String? ?? '',
      nomeFantasia: json['nome_fantasia'] as String? ?? '',
      cnpj: json['cnpj'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telefone: json['telefone'] as String? ?? '',
      cep: json['cep'] as String? ?? '',
      logradouro: json['logradouro'] as String? ?? '',
      numero: json['numero'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      cidade: json['cidade'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      status: json['status'] as String? ?? 'ativa',
      deletedAt: json['deleted_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
