import 'dart:typed_data';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:erp_alianca_dev/shared/pdf/pdf_logo.dart';
import 'package:erp_alianca_dev/shared/pdf/pdf_theme.dart';
import 'package:erp_alianca_dev/shared/pdf/romaneio_pdf_data.dart';

// Helpers locais (mesmo padrão do cupom_pdf, sem alterar o cupom).
String _moedaBr(double value) {
  return NumberFormat('#,##0.00', 'pt_BR').format(value).replaceAll('.', ',');
}

const Map<String, String> _acentos = {
  'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'é': 'e', 'ê': 'e',
  'í': 'i', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ú': 'u', 'ç': 'c',
  'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U', 'Ç': 'C',
};

/// Travessões e outros Unicode que a Helvetica não desenha → hífen ASCII.
const Map<String, String> _unicodeParaAscii = {
  '\u2014': '-', // em dash —
  '\u2013': '-', // en dash –
  '\u2010': '-', // hyphen
  '\u00a0': ' ', // non-breaking space
};

/// Garante texto só com caracteres que a fonte padrão do PDF (Helvetica) suporta.
String _ascii(String s) {
  if (s.isEmpty) return s;
  return s.split('').map((c) {
    final substituido = _acentos[c] ?? _unicodeParaAscii[c];
    if (substituido != null) return substituido;
    // Qualquer outro Unicode (ex.: símbolos) vira hífen para não quebrar o PDF.
    if (c.codeUnitAt(0) > 127) return '-';
    return c;
  }).join();
}

/// Altura disponível para a lista na A4. Conservador para impressão (margem de segurança).
const double _alturaDisponivelListaPt = 520.0;

/// Altura aproximada por linha: fontSize * 1.2 (line height) + paddingVertical*2 + marginBottom.
double _alturaPorLinha(int fontSize, double paddingVertical, double marginBottom) {
  return fontSize * 1.2 + paddingVertical * 2 + marginBottom;
}

/// Reduz fonte e espaçamento para que [numItens] linhas caibam em uma página (evita quebra ao imprimir).
(int fontSize, double paddingVertical, double marginBottom) _estiloListaParaCaberEmUmaPagina(int numItens) {
  const padrao = (10, 5.0, 3.0);
  if (numItens <= 15) return padrao;
  final alturaMaxPorLinha = _alturaDisponivelListaPt / numItens;
  if (_alturaPorLinha(10, 5.0, 3.0) <= alturaMaxPorLinha) return padrao;
  if (_alturaPorLinha(8, 3.0, 2.0) <= alturaMaxPorLinha) return (8, 3.0, 2.0);
  if (_alturaPorLinha(7, 2.0, 1.0) <= alturaMaxPorLinha) return (7, 2.0, 1.0);
  if (_alturaPorLinha(6, 1.5, 1.0) <= alturaMaxPorLinha) return (6, 1.5, 1.0);
  if (_alturaPorLinha(5, 1.0, 0.5) <= alturaMaxPorLinha) return (5, 1.0, 0.5);
  final fontSize = (alturaMaxPorLinha / 1.5).clamp(4.0, 5.0).toInt();
  final restante = alturaMaxPorLinha - fontSize * 1.2 - 0.5;
  final padding = (restante / 2).clamp(0.5, 2.0);
  return (fontSize, padding, 0.5);
}

/// Gera o PDF do romaneio. Não faz HTTP; recebe [RomaneioPdfData].
/// Reduz fonte e espaçamento da lista de produtos quando há muitos itens, para caber em uma página.
Future<Uint8List> buildRomaneioPdf(RomaneioPdfData data) async {
  await initializeDateFormatting('pt_BR');
  const pageFormat = PdfPageFormat.a4;
  const margin = 36.0;

  final (fontSize, paddingVertical, marginBottom) = _estiloListaParaCaberEmUmaPagina(data.produtos.length);
  final style = pw.TextStyle(fontSize: fontSize.toDouble(), color: PdfColors.black);
  final styleBold = pw.TextStyle(fontSize: fontSize.toDouble(), fontWeight: pw.FontWeight.bold, color: PdfColors.black);
  final styleTotal = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900);

  final dataFormatada = DateFormat('dd/MM/yyyy', 'pt_BR').format(data.data);

  final theme = await getPdfTheme();
  final logoBytes = await loadPdfLogoBytes();
  final doc = pw.Document(theme: theme);
  doc.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      margin: const pw.EdgeInsets.all(margin),
      build: (pw.Context context) => [
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
        pw.Center(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey700,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              _ascii('ROMANEIO ${data.numeroRomaneio}'),
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            ),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Data: ${_ascii(dataFormatada)}', style: style),
            pw.Text('Status: ${_ascii(data.status)}', style: styleBold),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Placa: ${_ascii(data.placa.trim().isEmpty ? '----' : data.placa)}', style: style),
            pw.Text('Motorista: ${_ascii(data.motorista)}', style: style),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Divider(thickness: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 10),
        pw.Text('Resumo por produto', style: styleBold),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(flex: 1, child: pw.Text('Qtd', style: styleBold)),
            pw.Expanded(flex: 4, child: pw.Text('Produto', style: styleBold)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Divider(thickness: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 6),
        pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            for (final p in data.produtos)
              pw.Container(
                color: PdfColors.grey300,
                padding: pw.EdgeInsets.symmetric(vertical: paddingVertical, horizontal: 4),
                margin: pw.EdgeInsets.only(bottom: marginBottom),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 1, child: pw.Text('${p.quantidadeTotal}', style: style)),
                    pw.Expanded(flex: 4, child: pw.Text(_ascii(p.nomeProduto), style: style, maxLines: 1, overflow: pw.TextOverflow.clip)),
                  ],
                ),
              ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Divider(thickness: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('Total de volumes: ', style: styleBold),
                pw.Text('${data.totalVolumes}', style: styleTotal),
              ],
            ),
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('Total faturado: ', style: styleBold),
                pw.Text('R\$ ${_moedaBr(data.totalFaturado)}', style: styleTotal),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  return await doc.save();
}
