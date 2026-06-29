import 'package:intl/intl.dart';

final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
final NumberFormat _moedaFormat = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: 'R\$ ',
  decimalDigits: 2,
);
final NumberFormat _numeroFormat = NumberFormat.decimalPattern('pt_BR');

String formatarDataExibicao(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String formatarDataApi(DateTime date) => _apiDateFormat.format(date);

DateTime? parseDataApi(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String formatarMoedaDashboard(double value) => _moedaFormat.format(value);

String formatarNumeroDashboard(num value) => _numeroFormat.format(value);

String formatarPeriodoLabel(String periodo, String agrupamento) {
  if (periodo.isEmpty) return '—';
  final parsed = DateTime.tryParse(periodo);
  if (parsed == null) return periodo;
  switch (agrupamento) {
    case 'mensal':
      return DateFormat('MM/yyyy', 'pt_BR').format(parsed);
    case 'anual':
      return DateFormat('yyyy', 'pt_BR').format(parsed);
    default:
      return DateFormat('dd/MM', 'pt_BR').format(parsed);
  }
}

String labelStatusPedido(String status) {
  switch (status) {
    case 'rascunho':
      return 'Rascunho';
    case 'confirmado':
      return 'Confirmado';
    case 'organizado':
      return 'Organizado';
    case 'concluido':
      return 'Concluído';
    case 'cancelado':
      return 'Cancelado';
    default:
      return status.isEmpty ? '—' : status;
  }
}
