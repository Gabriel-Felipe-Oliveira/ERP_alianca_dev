import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';

/// Endereço em linha para exibição na UI (separador " — ").
String formatarEnderecoDisplay(ClienteModel c) {
  final parts = <String>[];
  final logrNum = [c.logradouro, c.numero]
      .where((s) => s.trim().isNotEmpty)
      .join(', ');
  if (logrNum.isNotEmpty) parts.add(logrNum);
  if (c.bairro.trim().isNotEmpty) parts.add(c.bairro);
  final cidadeEstado =
      '${c.cidade}/${c.estado}'.replaceAll(RegExp(r'/\s*$'), '').trim();
  if (cidadeEstado.isNotEmpty && cidadeEstado != '/') parts.add(cidadeEstado);
  if (c.cep.trim().isNotEmpty) parts.add('CEP ${c.cep}');
  return parts.isEmpty ? '—' : parts.join(' — ');
}

/// Endereço em linhas para recibo/PDF (rua, bairro, cidade/CEP).
String formatarEnderecoRecibo(ClienteModel c) {
  final logrNum = [c.logradouro, c.numero]
      .where((s) => s.trim().isNotEmpty)
      .join(', ');
  final linha1 = logrNum.isEmpty ? '' : 'Endereço: $logrNum';
  final linha2 = c.bairro.trim();
  final cidadeEstado =
      '${c.cidade}/${c.estado}'.replaceAll(RegExp(r'/\s*$'), '').trim();
  final cepPart = c.cep.trim().isNotEmpty ? 'CEP ${c.cep}' : '';
  final linha3 = [cidadeEstado, cepPart].where((s) => s.isNotEmpty).join(', ');
  final linhas = [linha1, linha2, linha3].where((s) => s.isNotEmpty);
  if (linhas.isEmpty) return '—';
  return linhas.join('\n');
}

/// Capitaliza cada palavra (ex.: "joao silva" → "Joao Silva").
String capitalizeWords(String s) {
  if (s.trim().isEmpty) return s;
  return s.split(' ').map((w) {
    if (w.isEmpty) return w;
    return w[0].toUpperCase() + w.substring(1).toLowerCase();
  }).join(' ');
}
