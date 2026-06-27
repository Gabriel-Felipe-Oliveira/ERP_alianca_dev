/// Resultado de uma operação de exportação/visualização de PDF.
class PdfExportResult {
  const PdfExportResult({
    this.success = true,
    this.message,
    this.isError = false,
  });

  const PdfExportResult.failure(String msg)
      : success = false,
        message = msg,
        isError = true;

  final bool success;
  final String? message;
  final bool isError;
}
