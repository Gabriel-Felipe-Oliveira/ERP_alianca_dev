import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Tema do PDF com fontes Unicode (OpenSans) para evitar erro "Helvetica has no Unicode support".
/// Carrega uma vez e pode ser reutilizado em romaneio_pdf e cupom_pdf.
/// Se o carregamento falhar (ex.: AssetManifest indisponível), usa tema padrão (Helvetica).
pw.ThemeData? _cachedPdfTheme;

Future<pw.ThemeData> getPdfTheme() async {
  if (_cachedPdfTheme != null) return _cachedPdfTheme!;
  try {
    final base = await PdfGoogleFonts.openSansRegular();
    final bold = await PdfGoogleFonts.openSansBold();
    final italic = await PdfGoogleFonts.openSansItalic();
    final boldItalic = await PdfGoogleFonts.openSansBoldItalic();
    _cachedPdfTheme = pw.ThemeData.withFont(
      base: base,
      bold: bold,
      italic: italic,
      boldItalic: boldItalic,
    );
    return _cachedPdfTheme!;
  } catch (_) {
    // Fallback: tema padrão (fontes built-in) quando fontes Google não carregam (ex.: AssetManifest).
    // Romaneio e cupom já usam _ascii() em textos para compatibilidade.
    _cachedPdfTheme = pw.ThemeData.base();
    return _cachedPdfTheme!;
  }
}
