/// Tipo do input: define formatação, validação e teclado.
enum AppInputType {
  /// Texto livre (padrão).
  text,

  /// E-mail: válido apenas com @ e .com
  email,

  /// DD do telefone: 2 dígitos
  telefoneDD,

  /// Número do telefone: 9 dígitos
  telefoneNumero,

  /// CEP: formato 00000-000, insere "-" após 5 dígitos
  cep,

  /// Estado (UF): 2 caracteres, sempre maiúsculo
  estado,

  /// Moeda: máscara X,XX; dígitos entram pela direita (0,01 → 0,10 → 1,00); primeiro dígito ≠ 0
  moeda,

  /// Placa de veículo (norma brasileira): formato antigo ABC1234 ou Mercosul ABC1D23
  placaVeiculo,

  /// CPF: máscara 000.000.000-00
  cpf,

  /// CNPJ: máscara 00.000.000/0000-00
  cnpj,
}
