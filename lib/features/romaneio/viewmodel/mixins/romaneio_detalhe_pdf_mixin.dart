import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:pdf_combiner/models/merge_input.dart';
import 'package:pdf_combiner/pdf_combiner.dart';
import 'package:erp_alianca_dev/core/utils/app_logger.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/pedidos/utils/pedido_cupom_builder.dart';
import 'package:erp_alianca_dev/features/pedidos/utils/pedido_pdf_nome_arquivo.dart';
import 'package:erp_alianca_dev/features/romaneio/model/produto_agregado.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/shared/models/pdf_export_result.dart';
import 'package:erp_alianca_dev/shared/pdf/romaneio_pdf.dart';
import 'package:erp_alianca_dev/shared/pdf/romaneio_pdf_data.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/cupom_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pdf_export_service.dart';
import 'package:erp_alianca_dev/shared/utils/cliente_formatters.dart';
import 'package:erp_alianca_dev/shared/utils/pdf_utils.dart';

/// Geração e exportação de PDFs do detalhe do romaneio.
mixin RomaneioDetalhePdfMixin on ChangeNotifier {
  RomaneioModel? get romaneioAtual;
  List<PedidoListagemModel> get pedidosDoRomaneioBase;
  Map<int, List<PedidoItemModel>> get itensPorPedido;
  List<ProdutoAgregado> get produtosAgregadosBase;
  int get totalVolumesBase;
  double get totalFaturadoBase;
  String Function(int idProduto) get resolverNomeProduto;
  String Function(RomaneioModel r) get formatarPlaca;
  String Function(RomaneioModel r) get formatarMotorista;
  String get errorMessagePdf;
  set errorMessagePdf(String value);

  ClienteService get clienteService;
  CupomService get cupomService;
  EmpresaService get empresaService;
  PdfExportService get pdfExportService;

  Future<bool> faturarMarcarConcluido();

  String nomeArquivoFaturaRomaneio() {
    final r = romaneioAtual;
    if (r == null) return 'Romaneio_Combo-00000.pdf';
    String numberPart;
    final numStr = r.numero.trim();
    if (numStr.isNotEmpty) {
      numberPart = numStr.contains('-')
          ? numStr.substring(numStr.lastIndexOf('-') + 1).trim()
          : numStr;
      final parsed = int.tryParse(numberPart);
      if (parsed != null) numberPart = parsed.toString().padLeft(5, '0');
    } else {
      numberPart = r.id != null ? r.id!.toString().padLeft(5, '0') : '00000';
    }
    return 'Romaneio_Combo-$numberPart.pdf';
  }

  String nomeArquivoPdfRomaneio() {
    final r = romaneioAtual;
    if (r?.id == null) return 'romaneio.pdf';
    return 'romaneio_${r!.id!.toString().padLeft(5, '0')}.pdf';
  }

  Future<Uint8List?> gerarPdfRomaneio() async {
    final r = romaneioAtual;
    if (r == null) return null;
    final produtosPdf = produtosAgregadosBase
        .map(
          (p) => ProdutoAgregadoPdf(
            nomeProduto: p.nome,
            quantidadeTotal: p.quantidadeTotal,
            subtotalTotal: p.subtotalTotal,
          ),
        )
        .toList();
    final data = RomaneioPdfData(
      numeroRomaneio: RomaneioModel.nomeExibicao(r),
      data: r.dataCriacao,
      status: r.status.label,
      placa: formatarPlaca(r),
      motorista: formatarMotorista(r),
      totalVolumes: totalVolumesBase,
      totalFaturado: totalFaturadoBase,
      produtos: produtosPdf,
    );
    return buildRomaneioPdf(data);
  }

  Future<List<({Uint8List? pdf, String nomeArquivo})>>
      gerarPdfsCuponsDosPedidos() async {
    final list = <({Uint8List? pdf, String nomeArquivo})>[];
    for (final pedido in pedidosDoRomaneioBase) {
      final itens = itensPorPedido[pedido.idPedido];
      if (itens == null || itens.isEmpty) {
        list.add((
          pdf: null,
          nomeArquivo: nomeArquivoReciboPedido(pedido.idPedido, ''),
        ));
        continue;
      }
      var nomeCliente = '—';
      var enderecoCliente = '—';
      if (pedido.idCliente > 0) {
        try {
          final cliente =
              await clienteService.buscarClientePorId(pedido.idCliente);
          nomeCliente =
              cliente.nome.trim().isNotEmpty ? cliente.nome : '—';
          enderecoCliente = formatarEnderecoRecibo(cliente);
        } catch (e) {
          AppLogger.debug(
              'Falha ao resolver cliente ${pedido.idCliente} no cupom: $e',
              tag: 'RomaneioDetalhePdf');
        }
      }
      final pedidoCupom = PedidoCupomBuilder.build(
        idPedido: pedido.idPedido,
        itens: itens,
        nomeCliente: nomeCliente,
        enderecoCliente: enderecoCliente,
        idCliente: pedido.idCliente,
        pedido: pedido,
        statusAtual: pedido.status,
        empresaService: empresaService,
        nomeProduto: resolverNomeProduto,
      );
      final nomeArquivo =
          nomeArquivoReciboPedido(pedido.idPedido, nomeCliente);
      if (pedidoCupom == null) {
        list.add((pdf: null, nomeArquivo: nomeArquivo));
        continue;
      }
      try {
        final bytes = await cupomService.gerarCupomPedido(pedidoCupom);
        list.add((pdf: bytes, nomeArquivo: nomeArquivo));
      } catch (_) {
        list.add((pdf: null, nomeArquivo: nomeArquivo));
      }
    }
    return list;
  }

  Future<Uint8List?> gerarPdfFaturaCompleto() async {
    try {
      final romaneioPdf = await gerarPdfRomaneio();
      if (romaneioPdf == null) return null;
      final cupomResultados = await gerarPdfsCuponsDosPedidos();
      final inputs = <MergeInput>[
        MergeInput.bytes(romaneioPdf),
        for (final r in cupomResultados)
          if (r.pdf != null) MergeInput.bytes(r.pdf!),
      ];
      if (inputs.length <= 1) return romaneioPdf;
      final dir = await getPastaPdfSubpasta(kSubpastaRomaneio);
      final id = romaneioAtual?.id ?? 0;
      final outputPath = p.join(dir.path, 'fatura_romaneio_$id.pdf');
      await PdfCombiner.mergeMultiplePDFs(
        inputs: inputs,
        outputPath: outputPath,
      );
      final bytes = await File(outputPath).readAsBytes();
      try {
        await File(outputPath).delete();
      } catch (_) {
        // best-effort: arquivo temporário será limpo pelo SO se persistir.
      }
      return bytes;
    } catch (e, st) {
      AppLogger.error(
        'Erro ao gerar PDF da fatura',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<void> exportarVisualizarPdf(BuildContext context) async {
    final pdfData = await gerarPdfRomaneio();
    if (pdfData == null || !context.mounted) return;
    await pdfExportService.abrirPreview(
      context,
      bytes: pdfData,
      tituloAppBar: 'PDF do Romaneio',
      nomeArquivoFallback: nomeArquivoPdfRomaneio(),
      subpastaFallback: kSubpastaRomaneio,
    );
  }

  Future<void> exportarSalvarPdf(BuildContext context) async {
    final pdfData = await gerarPdfRomaneio();
    if (pdfData == null || !context.mounted) return;
    await pdfExportService.salvarEAbrir(
      context,
      bytes: pdfData,
      nomeArquivo: nomeArquivoPdfRomaneio(),
      subpasta: kSubpastaRomaneio,
    );
  }

  Future<List<PdfExportResult>> exportarFaturar(BuildContext context) async {
    final results = <PdfExportResult>[];
    Uint8List? pdfCompleto;
    try {
      pdfCompleto = await gerarPdfFaturaCompleto();
    } catch (e, st) {
      AppLogger.error(
        'Erro ao gerar PDF da fatura',
        error: e,
        stackTrace: st,
      );
      results.add(
        const PdfExportResult.failure(
          'Erro ao gerar PDF. Verifique a conexão (fontes) e tente novamente.',
        ),
      );
      return results;
    }
    if (pdfCompleto == null) {
      results.add(
        const PdfExportResult.failure(
          'Erro ao gerar PDF. Verifique a conexão (fontes) e tente novamente.',
        ),
      );
      return results;
    }
    if (!context.mounted) return results;

    final salvou = await pdfExportService.salvarEAbrir(
      context,
      bytes: pdfCompleto,
      nomeArquivo: nomeArquivoFaturaRomaneio(),
      subpasta: kSubpastaRomaneio,
      showToast: false,
    );
    if (!salvou) {
      results.add(
        const PdfExportResult.failure(
          'Não foi possível salvar ou abrir o PDF.',
        ),
      );
      return results;
    }
    results.add(
      const PdfExportResult(
        message: 'Romaneio e recibos salvos em um único PDF e aberto.',
      ),
    );

    if (!context.mounted) return results;
    final ok = await faturarMarcarConcluido();
    if (ok) {
      results.add(
        const PdfExportResult(message: 'Romaneio marcado como concluído.'),
      );
    } else if (errorMessagePdf.isNotEmpty) {
      results.add(PdfExportResult.failure(errorMessagePdf));
    }
    return results;
  }
}
