import 'package:flutter/services.dart';

/// Máscara de moeda: valor digitado da esquerda para a direita.
/// Cada novo dígito entra na direita e o valor "empurra" para a esquerda.
/// Ex.: 0 → "0,00"; 1 → "0,01"; 0 → "0,10"; 0 → "1,00"; 1 → "10,01".
/// Formato exibido: X,XX (vírgula como separador decimal, 2 casas).
class CurrencyInputFormatter extends TextInputFormatter {
  static const int _maxDigits = 10; // até 99.999.999,99

  static int _textToCents(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 0;
    final parsed = int.tryParse(digits);
    return parsed ?? 0;
  }

  static String _centsToText(int cents) {
    if (cents <= 0) return '0,00';
    final reais = cents ~/ 100;
    final centavos = cents % 100;
    return '$reais,${centavos.toString().padLeft(2, '0')}';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldCents = _textToCents(oldValue.text);
    final newText = newValue.text;

    if (newText.isEmpty) {
      return TextEditingValue(
        text: '0,00',
        selection: const TextSelection.collapsed(offset: 4),
      );
    }

    // Um único dígito: inicia ou substitui o valor (0 permitido → "0,00")
    if (RegExp(r'^\d$').hasMatch(newText)) {
      final cents = int.parse(newText);
      final formatted = _centsToText(cents);
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // Inserção de um dígito no final (shift: novo dígito à direita)
    final onlyDigitsNew = newText.replaceAll(RegExp(r'\D'), '');
    final onlyDigitsOld = oldValue.text.replaceAll(RegExp(r'\D'), '');

    if (onlyDigitsNew.length == onlyDigitsOld.length + 1) {
      final addedChar = onlyDigitsNew[onlyDigitsNew.length - 1];
      final digit = int.tryParse(addedChar);
      if (digit != null) {
        final int newCents = oldCents * 10 + digit;
        if (newCents.toString().length > _maxDigits) return oldValue;
        final formatted = _centsToText(newCents);
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }

    // Backspace: remove último dígito
    if (onlyDigitsNew.length == onlyDigitsOld.length - 1 || newText.length < oldValue.text.length) {
      final newCents = oldCents ~/ 10;
      final formatted = _centsToText(newCents);
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // Cola ou edição estranha: tenta interpretar como número (só dígitos, até _maxDigits)
    if (onlyDigitsNew.isNotEmpty) {
      final limited = onlyDigitsNew.length > _maxDigits
          ? onlyDigitsNew.substring(0, _maxDigits)
          : onlyDigitsNew;
      final newCents = int.tryParse(limited) ?? 0;
      final formatted = _centsToText(newCents);
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return oldValue;
  }
}

/// Máscara CPF: 000.000.000-00 (11 dígitos).
class CpfInputFormatter extends TextInputFormatter {
  static const int _maxDigits = 11;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > _maxDigits) {
      return oldValue;
    }
    if (digitsOnly.isEmpty) {
      return newValue;
    }
    String formatted;
    if (digitsOnly.length <= 3) {
      formatted = digitsOnly;
    } else if (digitsOnly.length <= 6) {
      formatted =
          '${digitsOnly.substring(0, 3)}.${digitsOnly.substring(3)}';
    } else if (digitsOnly.length <= 9) {
      formatted =
          '${digitsOnly.substring(0, 3)}.${digitsOnly.substring(3, 6)}.${digitsOnly.substring(6)}';
    } else {
      formatted =
          '${digitsOnly.substring(0, 3)}.${digitsOnly.substring(3, 6)}.${digitsOnly.substring(6, 9)}-${digitsOnly.substring(9)}';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Máscara CNPJ: 00.000.000/0000-00 (14 dígitos).
class CnpjInputFormatter extends TextInputFormatter {
  static const int _maxDigits = 14;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > _maxDigits) {
      return oldValue;
    }
    if (digitsOnly.isEmpty) {
      return newValue;
    }
    String formatted;
    if (digitsOnly.length <= 2) {
      formatted = digitsOnly;
    } else if (digitsOnly.length <= 5) {
      formatted =
          '${digitsOnly.substring(0, 2)}.${digitsOnly.substring(2)}';
    } else if (digitsOnly.length <= 8) {
      formatted =
          '${digitsOnly.substring(0, 2)}.${digitsOnly.substring(2, 5)}.${digitsOnly.substring(5)}';
    } else if (digitsOnly.length <= 12) {
      formatted =
          '${digitsOnly.substring(0, 2)}.${digitsOnly.substring(2, 5)}.${digitsOnly.substring(5, 8)}/${digitsOnly.substring(8)}';
    } else {
      formatted =
          '${digitsOnly.substring(0, 2)}.${digitsOnly.substring(2, 5)}.${digitsOnly.substring(5, 8)}/${digitsOnly.substring(8, 12)}-${digitsOnly.substring(12)}';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Insere hífen após os 5 primeiros dígitos (CEP 00000-000).
class CepInputFormatter extends TextInputFormatter {
  static const int _digitsBeforeHyphen = 5;
  static const int _maxDigits = 8;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > _maxDigits) {
      return oldValue;
    }
    if (digitsOnly.isEmpty) {
      return newValue;
    }
    String formatted;
    if (digitsOnly.length <= _digitsBeforeHyphen) {
      formatted = digitsOnly;
    } else {
      formatted =
          '${digitsOnly.substring(0, _digitsBeforeHyphen)}-${digitsOnly.substring(_digitsBeforeHyphen)}';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Converte o texto para maiúsculo.
class UpperCaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Placa de veículo (norma brasileira): só letras e números, maiúsculo, máx. 7 caracteres.
/// Aceita formato antigo (ABC1234) e Mercosul (ABC1D23).
class PlacaVeiculoInputFormatter extends TextInputFormatter {
  static const int _maxLength = 7;
  static final RegExp _allow = RegExp(r'[A-Za-z0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final onlyValid = newValue.text
        .split('')
        .where((c) => _allow.hasMatch(c))
        .take(_maxLength)
        .join()
        .toUpperCase();
    if (onlyValid == newValue.text) return newValue;
    return TextEditingValue(
      text: onlyValid,
      selection: TextSelection.collapsed(offset: onlyValid.length),
    );
  }
}

/// Máscara de data: dd/MM/yyyy (8 dígitos).
class DateInputFormatter extends TextInputFormatter {
  static const int _maxDigits = 8;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > _maxDigits) {
      return oldValue;
    }
    if (digitsOnly.isEmpty) {
      return newValue;
    }
    String formatted;
    if (digitsOnly.length <= 2) {
      formatted = digitsOnly;
    } else if (digitsOnly.length <= 4) {
      formatted =
          '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2)}';
    } else {
      formatted =
          '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2, 4)}/${digitsOnly.substring(4)}';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
