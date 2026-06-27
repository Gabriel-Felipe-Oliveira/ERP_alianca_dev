import 'package:flutter/services.dart';

const String kPdfLogoAsset = 'assets/images/logo_empresa_1.png';

/// Carrega os bytes da logo para uso nos PDFs (pedido, romaneio).
/// Retorna null se o asset não existir ou falhar o carregamento.
Future<Uint8List?> loadPdfLogoBytes() async {
  try {
    final data = await rootBundle.load(kPdfLogoAsset);
    return data.buffer.asUint8List();
  } catch (_) {
    return null;
  }
}
