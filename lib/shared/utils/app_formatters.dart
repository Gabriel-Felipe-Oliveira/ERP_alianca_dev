/// Formatadores de exibição (não input). Usar em views e widgets compartilhados.
library;

/// Formata valor monetário para exibição: "1.234,56" (separador de milhares, vírgula decimal, sem símbolo).
/// Para exibir com R\$ use: 'R\$ ${formatarPreco(valor)}'.
String formatarPreco(double value) {
  final absValue = value.abs();
  final parts = absValue.toStringAsFixed(2).split('.');
  final intPart = parts[0];
  final decPart = parts[1];
  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
    buffer.write(intPart[i]);
  }
  final formatted = '${buffer.toString()},$decPart';
  return value < 0 ? '-$formatted' : formatted;
}

/// Formata data para exibição: dd/MM/yyyy.
String formatarData(DateTime value) {
  final d = value.day.toString().padLeft(2, '0');
  final m = value.month.toString().padLeft(2, '0');
  final y = value.year.toString();
  return '$d/$m/$y';
}

/// Formata data de nascimento para a API de clientes: dd/MM/yyyy.
String formatarDataNascimentoApi(DateTime value) => formatarData(value);

/// Converte data de nascimento da API (dd/MM/yyyy) para [DateTime].
DateTime? parseDataNascimentoApi(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parts = value.trim().split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}
