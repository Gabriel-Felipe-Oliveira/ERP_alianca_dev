import 'package:erp_alianca_dev/shared/utils/app_validators.dart';

/// Validadores centralizados do formulário de cliente (criar e editar).
/// ViewModels e Views devem usar estes métodos para manter regras em um só lugar.
abstract class ClienteValidator {
  /// Validador de nome no modo criar (label depende de CPF/CNPJ).
  static String? Function(String?) nomeCriar(bool isCpf) {
    final label = isCpf ? 'Nome completo' : 'Nome da empresa';
    return (String? v) => AppValidators.obrigatorio(v, label);
  }

  /// Validador de documento (CPF ou CNPJ) no modo criar.
  static String? Function(String?) documentoCriar(bool isCpf) {
    return isCpf
        ? (String? v) => AppValidators.cpf(v)
        : (String? v) => AppValidators.cnpj(v);
  }

  /// Validador de nome no modo editar.
  static String? nomeEditar(String? value) =>
      AppValidators.obrigatorio(value, 'Nome');

  /// Validador de documento no modo editar (CPF ou CNPJ conforme tipo).
  static String? Function(String?) documentoEditar(String tipoDocumento) {
    return tipoDocumento == 'cnpj'
        ? (String? v) => AppValidators.cnpj(v)
        : (String? v) => AppValidators.cpf(v);
  }

  /// Validador de logradouro (editar).
  static String? logradouroEditar(String? value) =>
      AppValidators.obrigatorio(value, 'Logradouro');

  /// Validador de número (editar).
  static String? numeroEditar(String? value) =>
      AppValidators.obrigatorio(value, 'Número');

  /// Validador de bairro (editar).
  static String? bairroEditar(String? value) =>
      AppValidators.obrigatorio(value, 'Bairro');

  /// Validador de cidade (editar).
  static String? cidadeEditar(String? value) =>
      AppValidators.obrigatorio(value, 'Cidade');

  /// Validador de estado UF (editar).
  static String? estadoEditar(String? value) => AppValidators.estado(value);

  /// Validador de CEP (editar).
  static String? cepEditar(String? value) => AppValidators.cep(value);

  /// Retorna lista de labels dos campos obrigatórios faltantes no modo criar.
  /// No criar apenas o nome é obrigatório.
  static List<String> camposFaltantesCriar(bool isCpf, String? nome) {
    final label = isCpf ? 'Nome completo' : 'Nome da empresa';
    if (AppValidators.obrigatorio(nome, label) != null) {
      return [label];
    }
    return [];
  }

  /// Indica se o formulário está válido no modo criar (apenas nome obrigatório).
  static bool isValidCriar(bool isCpf, String? nome) {
    return camposFaltantesCriar(isCpf, nome).isEmpty;
  }

  /// Indica se o formulário está válido no modo editar (todos os campos obrigatórios e formatos).
  static bool isValidEditar({
    required String? nome,
    required String? dd,
    required String? telefoneNumero,
    required String? email,
    required String? logradouro,
    required String? numero,
    required String? cep,
    required String? bairro,
    required String? cidade,
    required String? estado,
  }) {
    if (AppValidators.obrigatorio(nome, 'Nome') != null) return false;
    if (AppValidators.telefoneDD(dd) != null) return false;
    if (AppValidators.telefoneNumero(telefoneNumero) != null) return false;
    if (AppValidators.email(email) != null) return false;
    if (AppValidators.obrigatorio(logradouro, 'Logradouro') != null) return false;
    if (AppValidators.obrigatorio(numero, 'Número') != null) return false;
    if (AppValidators.cep(cep) != null) return false;
    if (AppValidators.obrigatorio(bairro, 'Bairro') != null) return false;
    if (AppValidators.obrigatorio(cidade, 'Cidade') != null) return false;
    if (AppValidators.estado(estado) != null) return false;
    return true;
  }
}
