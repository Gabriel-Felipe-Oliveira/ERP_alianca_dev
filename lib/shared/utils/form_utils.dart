import 'package:flutter/material.dart';

/// Utilitários para formulários. Sempre conferir se o campo não está null ao ler.
abstract class FormUtils {
  /// Retorna o texto do controller trimado; nunca retorna null (usa '' se null/vazio).
  static String safeText(TextEditingController? controller) {
    if (controller == null) return '';
    final text = controller.text;
    if (text.isEmpty) return '';
    return text.trim();
  }

  /// Retorna apenas os dígitos do texto do controller; nunca retorna null.
  static String safeDigits(TextEditingController? controller) {
    if (controller == null) return '';
    return controller.text.replaceAll(RegExp(r'\D'), '');
  }
}
