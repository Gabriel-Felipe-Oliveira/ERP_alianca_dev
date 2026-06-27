import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';

/// Edição de logística e pedidos vinculados no detalhe do romaneio.
mixin RomaneioDetalheEdicaoMixin on ChangeNotifier {
  bool get isVmDisposed;
  RomaneioService get romaneioService;
  PedidoService get pedidoService;
  EmpresaService get empresaService;
  RomaneioModel? get romaneioAtual;
  List<PedidoListagemModel> get pedidosDoRomaneioBase;
  String get errorMessageEdicao;
  set errorMessageEdicao(String value);
  String motoristaExibicao(RomaneioModel r);
  String placaExibicao(RomaneioModel r);
  Future<void> recarregarRomaneio();

  bool _isEditMode = false;
  TextEditingController? _motoristaEditController;
  TextEditingController? _placaEditController;
  final List<PedidoListagemModel> _pedidosEdit = [];
  List<PedidoListagemModel> _pedidosDisponiveisParaAdicionar = [];
  bool _isSalvandoEdicao = false;
  bool _isCarregandoPedidosParaAdicionar = false;

  bool get isEditMode => _isEditMode;
  TextEditingController? get motoristaEditController => _motoristaEditController;
  TextEditingController? get placaEditController => _placaEditController;
  List<PedidoListagemModel> get pedidosEdit => List.unmodifiable(_pedidosEdit);
  double get totalFaturadoEdit =>
      _pedidosEdit.fold<double>(0, (s, p) => s + p.total);
  List<PedidoListagemModel> get pedidosDisponiveisParaAdicionar =>
      List.unmodifiable(_pedidosDisponiveisParaAdicionar);
  bool get isSalvandoEdicao => _isSalvandoEdicao;
  bool get isCarregandoPedidosParaAdicionar => _isCarregandoPedidosParaAdicionar;

  void disposeEdicaoControllers() {
    _motoristaEditController?.dispose();
    _placaEditController?.dispose();
  }

  void enterEditMode() {
    final r = romaneioAtual;
    if (r == null) return;
    _motoristaEditController?.dispose();
    _placaEditController?.dispose();
    _motoristaEditController = TextEditingController(
      text: motoristaExibicao(r) == '—' ? '' : (r.nomeMotorista ?? ''),
    );
    _placaEditController = TextEditingController(
      text: placaExibicao(r) == '—' ? '' : (r.placaVeiculo ?? ''),
    );
    _pedidosEdit
      ..clear()
      ..addAll(pedidosDoRomaneioBase);
    _pedidosDisponiveisParaAdicionar = [];
    _isEditMode = true;
    if (!isVmDisposed) notifyListeners();
  }

  void exitEditMode() {
    _isEditMode = false;
    _motoristaEditController?.dispose();
    _placaEditController?.dispose();
    _motoristaEditController = null;
    _placaEditController = null;
    _pedidosEdit.clear();
    _pedidosDisponiveisParaAdicionar = [];
    if (!isVmDisposed) notifyListeners();
  }

  void removerPedidoDoRomaneio(PedidoListagemModel p) {
    _pedidosEdit.removeWhere((e) => e.idPedido == p.idPedido);
    if (!isVmDisposed) notifyListeners();
  }

  Future<void> carregarPedidosParaAdicionar() async {
    _isCarregandoPedidosParaAdicionar = true;
    if (!isVmDisposed) notifyListeners();
    try {
      final confirmados =
          await pedidoService.listarPedidos(status: 'confirmado');
      final idsNoRomaneio = _pedidosEdit.map((e) => e.idPedido).toSet();
      _pedidosDisponiveisParaAdicionar = confirmados
          .where((p) => !idsNoRomaneio.contains(p.idPedido))
          .toList();
    } catch (_) {
      _pedidosDisponiveisParaAdicionar = [];
    } finally {
      _isCarregandoPedidosParaAdicionar = false;
      if (!isVmDisposed) notifyListeners();
    }
  }

  void adicionarPedidoAoRomaneio(PedidoListagemModel p) {
    if (_pedidosEdit.any((e) => e.idPedido == p.idPedido)) return;
    _pedidosEdit.add(p);
    _pedidosDisponiveisParaAdicionar
        .removeWhere((e) => e.idPedido == p.idPedido);
    if (!isVmDisposed) notifyListeners();
  }

  Future<bool> salvarEdicao() async {
    final r = romaneioAtual;
    if (r?.id == null ||
        _motoristaEditController == null ||
        _placaEditController == null) {
      return false;
    }
    final idEmpresa = empresaService.idEmpresa;
    final idsOriginais = pedidosDoRomaneioBase.map((e) => e.idPedido).toSet();
    final idsEditados = _pedidosEdit.map((e) => e.idPedido).toSet();
    final idsRemovidos = idsOriginais.difference(idsEditados);
    final idsAdicionados = idsEditados.difference(idsOriginais);
    _isSalvandoEdicao = true;
    errorMessageEdicao = '';
    if (!isVmDisposed) notifyListeners();
    try {
      await romaneioService.atualizarRomaneio(
        idEmpresa: idEmpresa,
        idRomaneio: r!.id!,
        motoristaEntregador: _motoristaEditController!.text.trim().isEmpty
            ? 'Agregado'
            : _motoristaEditController!.text.trim(),
        placa: _placaEditController!.text.trim(),
        totalFaturado: totalFaturadoEdit,
        pedidosIds: _pedidosEdit.map((e) => e.idPedido).toList(),
      );
      for (final idPedido in idsRemovidos) {
        await pedidoService.alterarStatusPedido(
          idPedido,
          idEmpresa,
          'confirmado',
        );
      }
      for (final idPedido in idsAdicionados) {
        await pedidoService.alterarStatusPedido(
          idPedido,
          idEmpresa,
          'organizado',
        );
      }
      _isSalvandoEdicao = false;
      exitEditMode();
      await recarregarRomaneio();
      if (!isVmDisposed) notifyListeners();
      return true;
    } catch (e) {
      errorMessageEdicao = e is AppException
          ? e.message
          : (e is Exception
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Erro ao salvar.');
      _isSalvandoEdicao = false;
      if (!isVmDisposed) notifyListeners();
      return false;
    }
  }
}
