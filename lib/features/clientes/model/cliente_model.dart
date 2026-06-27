/// Model de dados do cliente (formulário e API).
/// [tipoDocumento]: 'cpf' ou 'cnpj'. [documento]: apenas dígitos (11 ou 14).
/// [nomeResponsavel]: opcional, usado quando tipoDocumento é 'cnpj'.
/// [nomeEmpresa]: opcional; se vazio enviamos '' na requisição.
class ClienteModel {
  /// Opções de status para dropdown (criar/editar).
  static const List<String> statusOpcoes = ['Ativo', 'Inativo'];
  final int? id;
  final int idEmpresa;
  final String tipoDocumento;
  final String documento;
  final String nome;
  final String? nomeResponsavel;
  final String? nomeEmpresa;
  final String telefone;
  final String email;
  final String cep;
  final String logradouro;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final String status;

  const ClienteModel({
    this.id,
    this.idEmpresa = 0,
    this.tipoDocumento = 'cpf',
    this.documento = '',
    required this.nome,
    this.nomeResponsavel,
    this.nomeEmpresa,
    required this.telefone,
    required this.email,
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.estado,
    this.status = 'Ativo',
  });

  /// Status no formato da API: "ativa" ou "inativa".
  String get _statusApi => status.toLowerCase() == 'ativo' ? 'ativa' : 'inativa';

  /// Retorna documento formatado para exibição (ex.: "CPF 123.456.789-00" ou "CNPJ 12.345.678/0001-90").
  /// Retorna null se documento estiver vazio.
  static String? formatarDocumentoParaExibicao(String tipoDocumento, String documento) {
    final digits = documento.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (tipoDocumento == 'cnpj' && digits.length == 14) {
      return 'CNPJ ${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
    }
    if (digits.length == 11) {
      return 'CPF ${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
    }
    return null;
  }

  /// Documento formatado para exibição (CPF ou CNPJ) ou null se vazio.
  String? get documentoFormatado => formatarDocumentoParaExibicao(tipoDocumento, documento);

  /// Retorna apenas o valor mascarado para preencher campo (ex.: 123.456.789-00 ou 12.345.678/0001-90).
  static String documentoMascaradoParaCampo(String tipoDocumento, String documento) {
    final digits = documento.replaceAll(RegExp(r'\D'), '');
    if (tipoDocumento == 'cnpj' && digits.length == 14) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
    }
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
    }
    return digits;
  }

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    final email = json['email_principal'] as String? ?? json['email'] as String? ?? '';
    final statusRaw = json['status'] as String? ?? 'Ativo';
    final statusNorm = statusRaw == 'ativa' || statusRaw == 'Ativo'
        ? 'Ativo'
        : (statusRaw == 'inativa' || statusRaw == 'Inativo' ? 'Inativo' : 'Ativo');
    final tipo = json['tipo_documento'] as String? ?? json['tipoDocumento'] as String? ?? 'cpf';
    final doc = (json['cpf_cnpj'] ?? json['documento'] ?? json['cpf'] ?? json['cnpj'])?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
    return ClienteModel(
      id: json['id'] as int? ?? json['id_cliente'] as int?,
      idEmpresa: json['id_empresa'] as int? ?? 0,
      tipoDocumento: tipo == 'cnpj' ? 'cnpj' : 'cpf',
      documento: doc,
      nome: json['nome'] as String? ?? '',
      nomeResponsavel: json['nome_responsavel'] as String? ?? json['nomeResponsavel'] as String?,
      nomeEmpresa: _emptyToNull(json['nome_empresa'] as String? ?? json['nomeEmpresa'] as String?),
      telefone: json['telefone'] as String? ?? '',
      email: email,
      cep: json['cep'] as String? ?? '',
      logradouro: json['logradouro'] as String? ?? '',
      numero: json['numero'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      cidade: json['cidade'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      status: statusNorm,
    );
  }

  static String? _emptyToNull(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  /// Payload no formato esperado pela API (criar/atualizar cliente).
  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      if (id != null) 'id_cliente': id,
      'id_empresa': idEmpresa,
      'nome': nome,
      'telefone': telefone,
      'email_principal': email,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'status': _statusApi,
    };
    // API usa o mesmo campo cpf_cnpj para o número (11 dígitos CPF ou 14 dígitos CNPJ).
    if (documento.isNotEmpty) payload['cpf_cnpj'] = documento;
    if (nomeEmpresa != null && nomeEmpresa!.trim().isNotEmpty) {
      payload['nome_empresa'] = nomeEmpresa!.trim();
    }
    if (tipoDocumento == 'cnpj' &&
        nomeResponsavel != null &&
        nomeResponsavel!.trim().isNotEmpty) {
      payload['nome_responsavel'] = nomeResponsavel!.trim();
    }
    return payload;
  }
}
