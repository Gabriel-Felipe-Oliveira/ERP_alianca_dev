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
