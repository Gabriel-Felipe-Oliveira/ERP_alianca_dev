import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';

/// Valores do formulário de cliente (extraídos dos controllers).
/// Usado para construir [ClienteModel] em um único lugar (criar e editar).
class ClienteFormValues {
  final String tipoDocumento;
  final String documentoDigits;
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

  const ClienteFormValues({
    required this.tipoDocumento,
    required this.documentoDigits,
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
    required this.status,
  });

  /// Converte para [ClienteModel] para envio à API.
  /// [idEmpresa] e opcionalmente [id] (para edição); [nomeResponsavel] pode ser
  /// passado na edição quando não existe campo no formulário.
  ClienteModel toModel(
    int idEmpresa, {
    int? id,
    String? nomeResponsavelOverride,
  }) {
    final nomeResp = nomeResponsavelOverride ?? nomeResponsavel;
    final nomeEmp = nomeEmpresa?.trim();
    return ClienteModel(
      id: id,
      idEmpresa: idEmpresa,
      tipoDocumento: tipoDocumento,
      documento: documentoDigits,
      nome: nome,
      nomeResponsavel: nomeResp?.trim().isEmpty == true ? null : nomeResp?.trim(),
      nomeEmpresa: nomeEmp == null || nomeEmp.isEmpty ? null : nomeEmp,
      telefone: telefone,
      email: email,
      cep: cep,
      logradouro: logradouro,
      numero: numero,
      bairro: bairro,
      cidade: cidade,
      estado: estado,
      status: status,
    );
  }
}
