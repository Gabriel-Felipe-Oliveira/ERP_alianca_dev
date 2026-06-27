import 'dart:typed_data';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:erp_alianca_dev/shared/pdf/cupom_pedido_data.dart';
import 'package:erp_alianca_dev/shared/pdf/pdf_logo.dart';
import 'package:erp_alianca_dev/shared/pdf/pdf_theme.dart';

/// Formata valor em reais: "12,50".
String _moedaBr(double value) {
  return NumberFormat('#,##0.00', 'pt_BR').format(value).replaceAll('.', ',');
}

/// Converte para ASCII para evitar erro quando a fonte não tem Unicode.
const Map<String, String> _acentos = {
  'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a', 'ª': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'º': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
  'Á': 'A', 'À': 'A', 'Ã': 'A', 'Â': 'A', 'Ä': 'A',
  'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
  'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
  'Ó': 'O', 'Ò': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö': 'O',
  'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
  'Ç': 'C', 'Ñ': 'N',
};

String _ascii(String s) {
  if (s.isEmpty) return s;
  return s.split('').map((c) => _acentos[c] ?? c).join();
}

/// Gera o PDF do recibo no layout da tela (recibo com cabeçalho, cliente, tabela e total).
/// Não faz HTTP; recebe [pedido] como parâmetro.
/// [larguraMm] é ignorado; o recibo usa página A4.
Future<Uint8List> buildCupomPdf(Pedido pedido, {double larguraMm = 80}) async {
  await initializeDateFormatting('pt_BR');
  // A4 retrato (vertical) para recibo e impressão padrão.
  const pageFormat = PdfPageFormat.a4;
  const marginHorizontal = 20.0;
  const marginTop = 12.0;
  const marginBottom = 16.0;
  const fontSize = 11.0;
  const fontSizeSmall = 10.0;

  final style = pw.TextStyle(fontSize: fontSize, color: PdfColors.black);
  final styleBold = pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold, color: PdfColors.black);
  final styleSmall = pw.TextStyle(fontSize: fontSizeSmall, color: PdfColors.black);
  final styleTotal = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900);

  final dataHora = DateFormat("d 'de' MMMM 'de' yyyy 'às' HH:mm", 'pt_BR').format(pedido.data);

  final theme = await getPdfTheme();
  final logoBytes = await loadPdfLogoBytes();
  final doc = pw.Document(theme: theme);
  doc.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      margin: const pw.EdgeInsets.only(
        left: marginHorizontal,
        right: marginHorizontal,
        top: marginTop,
        bottom: marginBottom,
      ),
      build: (pw.Context context) => [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            if (logoBytes != null) ...[
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(logoBytes),
                  width: 240,
                  height: 100,
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.SizedBox(height: 8),
            ],

            // Cliente + endereço
            pw.Text(
              pedido.clienteCod.isNotEmpty
                  ? '${pedido.clienteCod} ${_ascii(pedido.clienteNome)}'
                  : _ascii(pedido.clienteNome),
              style: styleBold,
              maxLines: 2,
              overflow: pw.TextOverflow.clip,
            ),
            if (pedido.enderecoCliente.isNotEmpty && pedido.enderecoCliente != '—') ...[
              pw.SizedBox(height: 1),
              ...pedido.enderecoCliente.split('\n').map(
                    (linha) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 0),
                      child: pw.Text(
                        _ascii(linha.trim()),
                        style: styleSmall,
                        maxLines: 2,
                        overflow: pw.TextOverflow.clip,
                      ),
                    ),
                  ),
            ],
            pw.SizedBox(height: 4),

            pw.Divider(thickness: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 2),

            pw.Center(
              child: pw.Text('Produtos / Serviços', style: styleBold),
            ),
            pw.SizedBox(height: 2),

            // Cabeçalho da tabela
            pw.Row(
              children: [
                pw.Expanded(flex: 1, child: pw.Text('Qtd', style: styleBold)),
                pw.Expanded(flex: 3, child: pw.Text('Nome', style: styleBold)),
                pw.Expanded(flex: 1, child: pw.Text('Preço', style: styleBold)),
                pw.Expanded(flex: 1, child: pw.Text('Valor', style: styleBold)),
              ],
            ),
            pw.SizedBox(height: 1),
            pw.Divider(thickness: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 2),

            // Linhas dos itens — pouco espaço entre linhas
            ...pedido.itens.map(
              (item) => pw.Container(
                color: PdfColors.grey300,
                padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                margin: const pw.EdgeInsets.only(bottom: 1),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(flex: 1, child: pw.Text('${item.quantidade}x', style: style)),
                    pw.Expanded(flex: 3, child: pw.Text(_ascii(item.nome), style: style, maxLines: 2, overflow: pw.TextOverflow.clip)),
                    pw.Expanded(flex: 1, child: pw.Text('R\$ ${_moedaBr(item.precoUnitario)}', style: style)),
                    pw.Expanded(flex: 1, child: pw.Text('R\$ ${_moedaBr(item.subtotal)}', style: style)),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 2),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('Subtotal: R\$ ${_moedaBr(pedido.subtotal)}', style: style),
              ],
            ),
            pw.SizedBox(height: 1),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('TOTAL: ', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.Text('R\$ ${_moedaBr(pedido.total)}', style: styleTotal),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('Pagamento: ', style: style),
                pw.Text(
                  _ascii(
                    pedido.formaPagamento.trim().isEmpty
                        ? '—'
                        : pedido.formaPagamento.trim(),
                  ),
                  style: styleBold,
                ),
              ],
            ),

            pw.SizedBox(height: 4),

            pw.Center(
              child: pw.Text(
                _ascii(dataHora),
                style: styleSmall,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  return await doc.save();
}
