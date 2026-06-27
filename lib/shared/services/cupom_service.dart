import 'dart:typed_data';

import 'package:erp_alianca_dev/shared/pdf/cupom_pedido_data.dart';
import 'package:erp_alianca_dev/shared/pdf/cupom_pdf.dart';

/// Serviço de geração de cupom térmico (PDF).
/// Não faz HTTP; apenas monta o PDF a partir do objeto [Pedido].
/// Arquivo: shared/services/cupom_service.dart (conforme convenção do projeto).
class CupomService {
  /// Gera o PDF do cupom no formato térmico (58mm ou 80mm).
  /// Recebe um [Pedido]; não usa caminho base nem arquivo.
  Future<Uint8List> gerarCupomPedido(Pedido pedido, {double larguraMm = 80}) async {
    return await buildCupomPdf(pedido, larguraMm: larguraMm);
  }
}
