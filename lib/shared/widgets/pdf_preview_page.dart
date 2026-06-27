import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Tela reutilizável de preview de PDF (AppBar + PdfPreview).
class PdfPreviewPage extends StatelessWidget {
  const PdfPreviewPage({
    super.key,
    required this.title,
    required this.pdfBytes,
  });

  final String title;
  final Uint8List pdfBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth * 0.5;
          return PdfPreview(
            build: (_) => Future.value(pdfBytes),
            allowPrinting: false,
            allowSharing: false,
            maxPageWidth: maxWidth.clamp(200.0, 600.0),
            dpi: 200,
          );
        },
      ),
    );
  }
}
