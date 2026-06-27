import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/models/pdf_export_result.dart';
import 'package:erp_alianca_dev/shared/utils/pdf_utils.dart';
import 'package:erp_alianca_dev/shared/widgets/pdf_preview_page.dart';

/// Orquestra preview e salvamento de PDFs (sem geração de bytes).
class PdfExportService {
  /// Abre preview in-app; se falhar, salva e abre com o visualizador do sistema.
  Future<void> abrirPreview(
    BuildContext context, {
    required Uint8List bytes,
    required String tituloAppBar,
    required String nomeArquivoFallback,
    required String subpastaFallback,
  }) async {
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => PdfPreviewPage(
            title: tituloAppBar,
            pdfBytes: bytes,
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      await salvarPdfEAbrir(
        context,
        bytes,
        nomeArquivoFallback,
        subpasta: subpastaFallback,
      );
    }
  }

  /// Salva PDF em Documentos/base_vendas/[subpasta] e abre com app padrão.
  Future<bool> salvarEAbrir(
    BuildContext context, {
    required List<int> bytes,
    required String nomeArquivo,
    String? subpasta,
    bool showToast = true,
  }) {
    return salvarPdfEAbrir(
      context,
      bytes,
      nomeArquivo,
      subpasta: subpasta,
      showToast: showToast,
    );
  }

  /// Salva sem toast e retorna resultado para a ViewModel.
  Future<PdfExportResult> salvarEAbrirComResultado(
    BuildContext context, {
    required List<int> bytes,
    required String nomeArquivo,
    String? subpasta,
  }) async {
    final ok = await salvarEAbrir(
      context,
      bytes: bytes,
      nomeArquivo: nomeArquivo,
      subpasta: subpasta,
      showToast: false,
    );
    if (!context.mounted) {
      return const PdfExportResult(success: false);
    }
    if (ok) {
      return const PdfExportResult(
        message: 'PDF salvo e aberto.',
      );
    }
    return const PdfExportResult.failure(
      'Não foi possível salvar ou abrir o PDF.',
    );
  }
}
