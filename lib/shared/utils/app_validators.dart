/// Validadores reutilizáveis por tipo de input.
/// Regra: sempre conferir se o valor não está null (e vazio) no início de cada validador.
abstract class AppValidators {
  /// Campo obrigatório genérico (campos sem definição): não pode ser vazio.
  static String? obrigatorio(String? value, String nomeCampo) {
    if (value == null || value.trim().isEmpty) {
      return '$nomeCampo não pode ser vazio';
    }
    return null;
  }

  /// E-mail: opcional. Se preenchido, deve conter @ e .com
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final v = value.trim();
    if (!v.contains('@')) {
      return 'E-mail deve conter @';
    }
    if (!v.contains('.com')) {
      return 'E-mail deve conter .com';
    }
    return null;
  }

  /// CEP: opcional. Se preenchido, formato 00000-000 (8 dígitos)
  static String? cep(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final match = RegExp(r'^\d{5}-?\d{3}$').firstMatch(value.replaceAll(' ', ''));
    if (match == null) {
      return 'CEP deve estar no formato 00000-000';
    }
    return null;
  }

  /// Estado (UF): opcional. Se preenchido, exatamente 2 caracteres
  static String? estado(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length != 2) {
      return 'Estado deve ter 2 caracteres (UF)';
    }
    return null;
  }

  /// DD (telefone): opcional. Se preenchido, exatamente 2 dígitos
  static String? telefoneDD(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.replaceAll(RegExp(r'\D'), '').length != 2) {
      return 'DD deve ter 2 dígitos';
    }
    return null;
  }

  /// Número de telefone: opcional. Se preenchido, entre 6 e 9 dígitos.
  static String? telefoneNumero(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6 || digits.length > 9) {
      return 'Número deve ter entre 6 e 9 dígitos';
    }
    return null;
  }

  /// Número decimal não negativo (ex.: preço).
  static String? preco(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Preço é obrigatório';
    }
    final n = double.tryParse(value.trim().replaceAll(',', '.'));
    if (n == null || n < 0) {
      return 'Preço deve ser um número maior ou igual a zero';
    }
    return null;
  }

  /// Inteiro não negativo (ex.: estoque).
  static String? inteiroNaoNegativo(String? value, String nomeCampo) {
    if (value == null || value.trim().isEmpty) {
      return '$nomeCampo é obrigatório';
    }
    final n = int.tryParse(value.trim());
    if (n == null || n < 0) {
      return '$nomeCampo deve ser um número inteiro maior ou igual a zero';
    }
    return null;
  }

  /// CPF: opcional. Se preenchido, deve ter 11 dígitos (máscara 000.000.000-00).
  static String? cpf(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return 'CPF deve ter 11 dígitos';
    return null;
  }

  /// CNPJ: opcional. Se preenchido, deve ter 14 dígitos (máscara 00.000.000/0000-00).
  static String? cnpj(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return 'CNPJ deve ter 14 dígitos';
    return null;
  }

  /// Placa de veículo: 7 caracteres (letras e números).
  /// Aceita formato antigo (ABC1234), Mercosul (ABC1D23) ou apenas 7 caracteres alfanuméricos.
  static String? placaVeiculo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Placa do veículo é obrigatória';
    }
    final normalizada = value
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[\s\-\.]'), '')
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (normalizada.length != 7) {
      return 'Placa deve ter 7 caracteres (ex.: ABC1234 ou ABC1D23)';
    }
    return null;
  }
}
