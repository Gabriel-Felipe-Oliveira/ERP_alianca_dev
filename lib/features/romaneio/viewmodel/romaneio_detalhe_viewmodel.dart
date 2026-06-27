import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/romaneio/model/produto_agregado.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/mixins/romaneio_detalhe_edicao_mixin.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/mixins/romaneio_detalhe_pdf_mixin.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/mixins/romaneio_detalhe_pedidos_mixin.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/cupom_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pdf_export_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';

export 'package:erp_alianca_dev/features/romaneio/model/produto_agregado.dart';

/// ViewModel da tela de detalhe do romaneio.
class RomaneioDetalheViewModel extends BaseViewModel
    with
        RomaneioDetalhePedidosMixin,
        RomaneioDetalheEdicaoMixin,
        RomaneioDetalhePdfMixin {
  RomaneioDetalheViewModel(
    this._romaneioService,
    this._pedidoService,
    this._produtoService,
    this._empresaService,
    this._clienteService,
    this._cupomService,
    this._pdfExportService, {
    required this.idRomaneio,
  });

  final RomaneioService _romaneioService;
  final PedidoService _pedidoService;
  final ProdutoService _produtoService;
  final EmpresaService _empresaService;
  final ClienteService _clienteService;
  final CupomService _cupomService;
  final PdfExportService _pdfExportService;
  final int idRomaneio;

  ViewState _state = ViewState.loading;
  String _errorMessage = '';
  RomaneioModel? _romaneio;
  List<PedidoListagemModel> _pedidosDoRomaneio = [];
  final Map<int, List<PedidoItemModel>> _itensPorPedido = {};
  final Map<int, String> _nomesProdutos = {};
  final Map<int, String> _nomesClientesPorPedido = {};
  bool _loadingPedidos = false;
  bool _isAlterandoStatus = false;
  bool _isArquivando = false;

  @override
  bool get isVmDisposed => isDisposed;

  @override
  RomaneioService get romaneioService => _romaneioService;

  @override
  PedidoService get pedidoService => _pedidoService;

  @override
  ProdutoService get produtoService => _produtoService;

  @override
  ClienteService get clienteService => _clienteService;

  @override
  CupomService get cupomService => _cupomService;

  @override
  EmpresaService get empresaService => _empresaService;

  @override
  PdfExportService get pdfExportService => _pdfExportService;

  @override
  RomaneioModel? get romaneioAtual => _romaneio;

  @override
  List<PedidoListagemModel> get pedidosDoRomaneioBase => _pedidosDoRomaneio;

  @override
  List<PedidoListagemModel> get pedidosDoRomaneioInterno => _pedidosDoRomaneio;

  @override
  set pedidosDoRomaneioInterno(List<PedidoListagemModel> value) {
    _pedidosDoRomaneio = value;
  }

  @override
  Map<int, List<PedidoItemModel>> get itensPorPedido => _itensPorPedido;

  @override
  Map<int, String> get nomesProdutos => _nomesProdutos;

  @override
  Map<int, String> get nomesClientesPorPedido => _nomesClientesPorPedido;

  @override
  bool get loadingPedidosInterno => _loadingPedidos;

  @override
  set loadingPedidosInterno(bool value) => _loadingPedidos = value;

  @override
  List<ProdutoAgregado> get produtosAgregadosBase => produtosAgregados;

  @override
  int get totalVolumesBase => totalVolumes;

  @override
  double get totalFaturadoBase => totalFaturado;

  @override
  String Function(int idProduto) get resolverNomeProduto => nomeProduto;

  @override
  String get errorMessageEdicao => _errorMessage;

  @override
  set errorMessageEdicao(String value) => _errorMessage = value;

  @override
  String get errorMessagePdf => _errorMessage;

  @override
  set errorMessagePdf(String value) => _errorMessage = value;

  @override
  Future<void> recarregarRomaneio() => loadRomaneio();

  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  RomaneioModel? get romaneio => _romaneio;
  List<PedidoListagemModel> get pedidosDoRomaneio =>
      List.unmodifiable(_pedidosDoRomaneio);
  bool get loadingPedidos => _loadingPedidos;
  bool get isAlterandoStatus => _isAlterandoStatus;
  bool get isArquivando => _isArquivando;

  bool get podeGerarPdf => !loadingPedidos;
  bool get podeFaturar => podeGerarPdf && pedidosDoRomaneio.isNotEmpty;

  @override
  void dispose() {
    disposeEdicaoControllers();
    super.dispose();
  }

  String formatarMoeda(double value) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 2,
    ).format(value);
  }

  Color corStatus(RomaneioStatus status) {
    switch (status) {
      case RomaneioStatus.concluido:
        return const Color(0xFF22C55E);
      case RomaneioStatus.emRota:
        return AppColors.primary;
      case RomaneioStatus.cancelado:
        return AppColors.error;
      case RomaneioStatus.rascunho:
        return AppColors.textSecondary;
    }
  }

  String textoNumeroRomaneio(RomaneioModel r) {
    return 'Romaneio ${RomaneioModel.nomeExibicao(r)}';
  }

  String dataFormatada(RomaneioModel r) {
    return DateFormat('dd/MM/yyyy').format(r.dataCriacao);
  }

  @override
  String Function(RomaneioModel r) get formatarPlaca => placaExibicao;

  @override
  String Function(RomaneioModel r) get formatarMotorista => motoristaExibicao;

  @override
  String placaExibicao(RomaneioModel r) {
    return r.placaVeiculo?.trim().isNotEmpty == true ? r.placaVeiculo! : '—';
  }

  @override
  String motoristaExibicao(RomaneioModel r) {
    return r.nomeMotorista?.trim().isNotEmpty == true ? r.nomeMotorista! : '—';
  }

  String valorFormatadoPedido(PedidoListagemModel p) => formatarMoeda(p.total);

  String idPedidoFormatado(PedidoListagemModel p) {
    return '#${p.idPedido.toString().padLeft(5, '0')}';
  }

  Future<void> loadRomaneio() async {
    _state = ViewState.loading;
    _errorMessage = '';
    _romaneio = null;
    limparDadosPedidos();
    notifyListeners();

    try {
      final r = await _romaneioService.obterRomaneio(idRomaneio);
      _romaneio = r;
      _state = r == null ? ViewState.error : ViewState.success;
      if (r == null) {
        _errorMessage = 'Romaneio não encontrado.';
      } else if (r.idPedidos.isNotEmpty) {
        await carregarPedidosEItens(r.idPedidos);
      }
    } catch (_) {
      _errorMessage = 'Erro ao carregar romaneio. Tente novamente.';
      _state = ViewState.error;
    }
    notifyListeners();
  }

  @override
  Future<bool> faturarMarcarConcluido() async {
    final r = _romaneio;
    if (r?.id == null) return false;
    if (r!.status == RomaneioStatus.concluido) return true;
    final idEmpresa = _empresaService.idEmpresa;
    _isAlterandoStatus = true;
    _errorMessage = '';
    notifyListeners();
    try {
      for (final pedido in _pedidosDoRomaneio) {
        await _pedidoService.alterarStatusPedido(
          pedido.idPedido,
          idEmpresa,
          'concluido',
        );
      }
      await _romaneioService.alterarStatusRomaneio(
        idEmpresa: idEmpresa,
        idRomaneio: r.id!,
        status: 'concluido',
      );
      _isAlterandoStatus = false;
      await loadRomaneio();
      if (!isDisposed) notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is AppException
          ? e.message
          : (e is Exception
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Erro ao marcar romaneio como concluído.');
      _isAlterandoStatus = false;
      if (!isDisposed) notifyListeners();
      return false;
    }
  }

  Future<bool> alterarStatusParaConcluido() async {
    final r = _romaneio;
    if (r?.id == null) return false;
    _isAlterandoStatus = true;
    _errorMessage = '';
    notifyListeners();
    try {
      await _romaneioService.alterarStatusRomaneio(
        idEmpresa: _empresaService.idEmpresa,
        idRomaneio: r!.id!,
        status: 'concluido',
      );
      _isAlterandoStatus = false;
      await loadRomaneio();
      if (!isDisposed) notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is AppException
          ? e.message
          : (e is Exception
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Erro ao alterar status.');
      _isAlterandoStatus = false;
      if (!isDisposed) notifyListeners();
      return false;
    }
  }

  Future<bool> cancelarRomaneio() async {
    final r = _romaneio;
    if (r?.id == null) return false;
    _isAlterandoStatus = true;
    _errorMessage = '';
    notifyListeners();
    try {
      await _romaneioService.alterarStatusRomaneio(
        idEmpresa: _empresaService.idEmpresa,
        idRomaneio: r!.id!,
        status: 'cancelado',
      );
      _isAlterandoStatus = false;
      await loadRomaneio();
      if (!isDisposed) notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is AppException
          ? e.message
          : (e is Exception
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Erro ao cancelar romaneio.');
      _isAlterandoStatus = false;
      if (!isDisposed) notifyListeners();
      return false;
    }
  }

  Future<bool> arquivarRomaneio() async {
    final r = _romaneio;
    if (r?.id == null) return false;
    final idEmpresa = _empresaService.idEmpresa;
    final idsPedidos = r!.idPedidos.isNotEmpty
        ? r.idPedidos
        : r.listaPedidos.map((p) => p.idPedido).toList();
    _isArquivando = true;
    _errorMessage = '';
    notifyListeners();
    try {
      for (final idPedido in idsPedidos) {
        await _pedidoService.arquivarPedido(idPedido, idEmpresa);
      }
      await _romaneioService.arquivarRomaneio(
        idEmpresa: idEmpresa,
        idRomaneio: r.id!,
      );
      _isArquivando = false;
      if (!isDisposed) notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is AppException
          ? e.message
          : (e is Exception
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Erro ao arquivar.');
      _isArquivando = false;
      if (!isDisposed) notifyListeners();
      return false;
    }
  }
}
