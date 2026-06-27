import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';

/// Abre o PDF no visualizador padrão do sistema (Windows, macOS, Linux, etc.).
/// No Windows evita o uso de Process.start/start que abria o cmd em vez do PDF.
Future<void> abrirPdf(String filePath) async {
  await OpenFile.open(filePath);
}

/// Retorna a pasta Documentos do usuário (ex.: C:\Users\<user>\Documentos no Windows).
Future<Directory> getPastaDocumentosUsuario() async {
  if (Platform.isWindows) {
    try {
      final result = await Process.run(
        'powershell',
        ['-Command', "[Environment]::GetFolderPath('MyDocuments')"],
        runInShell: false,
      );
      if (result.exitCode == 0) {
        final path = (result.stdout as String).trim();
        if (path.isNotEmpty) return Directory(path);
      }
    } catch (_) {}
  }
  return getApplicationDocumentsDirectory();
}

/// Pasta principal em Documentos onde ficam os PDFs (base_vendas).
const String kPastaBaseVendas = 'base_vendas';

/// Subpasta para PDFs de romaneio: Documentos/base_vendas/romaneio
const String kSubpastaRomaneio = 'romaneio';

/// Subpasta para PDFs de pedidos/recibos: Documentos/base_vendas/pedido
const String kSubpastaPedido = 'pedido';

/// Cria as pastas Documentos/base_vendas, base_vendas/pedido e base_vendas/romaneio na primeira execução.
/// Deve ser chamado no startup do app (main) para evitar criar pastas na hora de gerar PDF.
Future<void> garantirPastasPdfCriadas() async {
  try {
    final base = await getPastaDocumentosUsuario();
    final baseVendas = Directory(p.join(base.path, kPastaBaseVendas));
    if (!await baseVendas.exists()) await baseVendas.create(recursive: true);
    final dirPedido = Directory(p.join(baseVendas.path, kSubpastaPedido));
    if (!await dirPedido.exists()) await dirPedido.create(recursive: true);
    final dirRomaneio = Directory(p.join(baseVendas.path, kSubpastaRomaneio));
    if (!await dirRomaneio.exists()) await dirRomaneio.create(recursive: true);
  } catch (_) {
    // Ignora falha na inicialização; getPastaPdfSubpasta ainda tenta criar na hora de salvar
  }
}

/// Retorna a pasta Documentos/base_vendas/[subpasta]. As pastas já devem existir (criadas no startup).
Future<Directory> getPastaPdfSubpasta(String subpasta) async {
  final base = await getPastaDocumentosUsuario();
  final dir = Directory(p.join(base.path, kPastaBaseVendas, subpasta));
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

/// Salva [bytes] como PDF em Documentos (ou em [subpasta] se informada), abre com o app padrão e mostra toast.
/// [subpasta]: opcional; ex. [kSubpastaRomaneio] ou [kSubpastaPedido]. Salva em Documentos/base_vendas/[subpasta].
/// [showToast]: se false, não exibe toast (útil ao salvar vários PDFs em sequência).
/// Retorna true se salvou e abriu com sucesso.
Future<bool> salvarPdfEAbrir(
  BuildContext context,
  List<int> bytes,
  String nomeArquivo, {
  String? subpasta,
  bool showToast = true,
}) async {
  try {
    final dir = subpasta != null && subpasta.isNotEmpty
        ? await getPastaPdfSubpasta(subpasta)
        : await getPastaDocumentosUsuario();
    final path = p.join(dir.path, nomeArquivo);
    final file = File(path);
    await file.writeAsBytes(bytes);
    if (!context.mounted) return false;
    await abrirPdf(path);
    if (showToast && context.mounted) {
      showAppToast(context, message: 'PDF salvo em:\n$path');
    }
    return true;
  } catch (_) {
    if (!context.mounted) return false;
    showAppToast(
      context,
      message: 'Não foi possível salvar ou abrir o PDF.',
      isError: true,
    );
    return false;
  }
}
