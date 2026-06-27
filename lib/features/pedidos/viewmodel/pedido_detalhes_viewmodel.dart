import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';
import 'package:erp_alianca_dev/features/pedidos/utils/pedido_pdf_nome_arquivo.dart';
import 'package:erp_alianca_dev/shared/services/pdf_export_service.dart';
import 'package:erp_alianca_dev/shared/utils/pdf_utils.dart';
import 'package:erp_alianca_dev/features/pedidos/contracts/pedido_selecao_produtos_contract.dart';
import 'package:erp_alianca_dev/features/pedidos/model/item_pedido_linha.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/pedidos/utils/pedido_calculator.dart';
import 'package:erp_alianca_dev/features/pedidos/utils/pedido_confirmacao_erro.dart';
import 'package:erp_alianca_dev/features/pedidos/utils/pedido_cupom_builder.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/mixins/pedido_detalhe_edicao_mixin.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/mixins/pedido_produto_busca_mixin.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/pdf/cupom_pedido_data.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/cupom_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import 'package:erp_alianca_dev/shared/utils/cliente_formatters.dart';

/// ViewModel da tela de detalhes do pedido.
class PedidoDetalhesViewModel extends BaseViewModel
    with PedidoProdutoBuscaMixin, PedidoDetalheEdicaoMixin
    implements PedidoSelecaoProdutosVm {
  PedidoDetalhesViewModel(
    this._pedidoService,
    this._produtoService,
    this._empresaService,
    this._cupomService,
    this._clienteService,
    this._pdfExportService, {
    required this.idPedido,
    PedidoListagemModel? pedido,
    String? nomeCliente,
  })  : _pedido = pedido,
        _nomeCliente = nomeCliente ?? '—' {
    initProdutoBuscaListeners();
    initEdicaoListeners();
  }

  final PedidoService _pedidoService;
  final ProdutoService _produtoService;
  final EmpresaService _empresaService;
  final CupomService _cupomService;
  final ClienteService _clienteService;
  final PdfExportService _pdfExportService;
  final int idPedido;

  PedidoListagemModel? _pedido;
  String _nomeCliente;
  String _enderecoCliente = '—';
  ViewState _state = ViewState.idle;
  String _errorMessage = '';
  bool _isDeleting = false;
  bool _isConfirming = false;
  bool _isCancelling = false;
  bool _statusConfirmado = false;
  final List<PedidoItemModel> _itens = [];
  final Map<int, String> _nomesProdutos = {};
  @override
  bool get isVmDisposed => isDisposed;

  @override
  PedidoService get pedidoService => _pedidoService;

  @override
  ProdutoService get produtoService => _produtoService;

  @override
  EmpresaService get empresaService => _empresaService;

  @override
  int get pedidoId => idPedido;

  @override
  String get statusAtualPedido => statusAtual;

  @override
  List<PedidoItemModel> get itensEditaveis => _itens;

  @override
  PedidoListagemModel? get pedidoAtual => _pedido;

  @override
  set pedidoAtual(PedidoListagemModel? value) => _pedido = value;

  @override
  String get errorMessageEdicao => _errorMessage;

  @override
  set errorMessageEdicao(String value) => _errorMessage = value;

  @override
  Future<void> reloadItens() => loadItens();

  @override
  void sairModoEdicao() => cancelarAdicionarProduto();

  bool get isDeleting => _isDeleting;
  bool get isConfirming => _isConfirming;
  bool get isCancelling => _isCancelling;

  String get statusAtual =>
      _statusConfirmado ? 'confirmado' : (_pedido?.status ?? '');

  PedidoListagemModel? get pedido => _pedido;
  String get nomeCliente => _nomeCliente;

  String get pagamentoExibicao {
    final p = _pedido?.pagamento.trim() ?? '';
    if (p.isEmpty) return '—';
    return p;
  }

  int get idCliente => _pedido?.idCliente ?? 0;

  String get idClienteFormatado {
    final id = idCliente;
    if (id <= 0) return '—';
    return '#${id.toString().padLeft(3, '0')}';
  }

  String get idClienteENomeCliente => '$idClienteFormatado $_nomeCliente'.trim();
  String get enderecoFormatado => _enderecoCliente;

  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  List<PedidoItemModel> get itens => List.unmodifiable(_itens);

  double get totalPedido => PedidoCalculator.totalItens(_itens);

  String nomeProduto(int idProduto) =>
      _nomesProdutos[idProduto] ?? 'Produto #$idProduto';

  @override
  Future<void> adicionarItens(List<ItemPedidoLinha> itens) async {
    if (itens.isEmpty) return;
    try {
      for (final item in itens) {
        final idProduto = item.produto.idProduto;
        if (idProduto == null) continue;
        await _pedidoService.adicionarItem(
          PedidoItemPayload(
            idPedido: idPedido,
            idEmpresa: _empresaService.idEmpresa,
            idProduto: idProduto,
            quantidade: item.quantidade,
            valorDesconto: item.valorEfetivo,
          ),
        );
      }
      await loadItens();
    } catch (_) {
      _errorMessage = 'Erro ao adicionar itens. Tente novamente.';
      if (!isDisposed) notifyListeners();
    }
  }

  Future<void> confirmarAdicionarItem() async {
    final p = produtoSelecionadoParaAdicionar;
    if (p == null || p.idProduto == null) return;
    final qtd = int.tryParse(quantidadeAdicionarController.text.trim()) ?? 0;
    if (qtd < 1) return;
    try {
      await _pedidoService.adicionarItem(
        PedidoItemPayload(
          idPedido: idPedido,
          idEmpresa: _empresaService.idEmpresa,
          idProduto: p.idProduto!,
          quantidade: qtd,
          valorDesconto: p.preco,
        ),
      );
      cancelarAdicionarProduto();
      await loadItens();
    } catch (_) {
      _errorMessage = 'Erro ao adicionar item. Tente novamente.';
    }
    if (!isDisposed) notifyListeners();
  }

  Future<void> loadItens() async {
    _state = ViewState.loading;
    _errorMessage = '';
    _itens.clear();
    limparAlteracoesPendentes();
    _enderecoCliente = '—';
    if (!isDisposed) notifyListeners();

    try {
      final lista = await _pedidoService.listarItensPedido(idPedido);
      _itens.addAll(lista);
      try {
        final cabecalho = await _pedidoService.listarPedidosPorIds([idPedido]);
        if (cabecalho.isNotEmpty) {
          _pedido = cabecalho.first;
        }
      } catch (_) {}
      _nomesProdutos.clear();
      final idsUnicos = lista.map((e) => e.idProduto).toSet();
      for (final id in idsUnicos) {
        try {
          final produto = await _produtoService.buscarPorId(id);
          if (produto != null && produto.nome.isNotEmpty) {
            _nomesProdutos[id] = produto.nome;
          }
        } catch (_) {
          // Mantém "Produto #id" se o produto foi arquivado ou a API falhar.
        }
      }
      final idClienteVal = _pedido?.idCliente ?? 0;
      if (idClienteVal > 0) {
        try {
          final cliente = await _clienteService.buscarClientePorId(idClienteVal);
          _enderecoCliente = formatarEnderecoRecibo(cliente);
          if (cliente.nome.trim().isNotEmpty) {
            _nomeCliente = cliente.nome;
          }
        } catch (_) {
          _enderecoCliente = '—';
        }
      }
      _state = ViewState.success;
    } catch (_) {
      _errorMessage = 'Erro ao carregar itens do pedido. Tente novamente.';
      _state = ViewState.error;
    }
    if (!isDisposed) notifyListeners();
  }

  Pedido? buildPedidoCupom() {
    return PedidoCupomBuilder.build(
      idPedido: idPedido,
      itens: _itens,
      nomeCliente: _nomeCliente,
      enderecoCliente: _enderecoCliente,
      idCliente: idCliente,
      pedido: _pedido,
      statusAtual: statusAtual,
      empresaService: _empresaService,
      nomeProduto: nomeProduto,
    );
  }

  Future<Uint8List?> gerarCupomPdf({double larguraMm = 80}) async {
    final pedidoCupom = buildPedidoCupom();
    if (pedidoCupom == null) return null;
    return _cupomService.gerarCupomPedido(pedidoCupom, larguraMm: larguraMm);
  }

  /// Preview in-app do cupom (PdfExportService).
  Future<void> exportarVisualizarCupom(BuildContext context) async {
    final pdfData = await gerarCupomPdf();
    if (pdfData == null || !context.mounted) return;
    await _pdfExportService.abrirPreview(
      context,
      bytes: pdfData,
      tituloAppBar: 'Cupom do pedido',
      nomeArquivoFallback: nomeArquivoReciboPedido(idPedido, _nomeCliente),
      subpastaFallback: kSubpastaPedido,
    );
  }

  /// Salva cupom em Documentos/base_vendas/pedido e abre.
  Future<void> exportarSalvarCupom(BuildContext context) async {
    final pdfData = await gerarCupomPdf();
    if (pdfData == null || !context.mounted) return;
    await _pdfExportService.salvarEAbrir(
      context,
      bytes: pdfData,
      nomeArquivo: nomeArquivoReciboPedido(idPedido, _nomeCliente),
      subpasta: kSubpastaPedido,
    );
  }

  Future<bool?> confirmarPedido() async {
    if (statusAtual == 'confirmado') return false;
    if (_isConfirming) return null;
    _isConfirming = true;
    _errorMessage = '';
    if (!isDisposed) notifyListeners();

    try {
      await _pedidoService.alterarStatusPedido(
        idPedido,
        _empresaService.idEmpresa,
        'confirmado',
      );
      _statusConfirmado = true;
      if (_pedido != null) {
        _pedido = PedidoListagemModel(
          idPedido: _pedido!.idPedido,
          idEmpresa: _pedido!.idEmpresa,
          idCliente: _pedido!.idCliente,
          status: 'confirmado',
          total: _pedido!.total,
          volume: _pedido!.volume,
          createdAt: _pedido!.createdAt,
          pagamento: _pedido!.pagamento,
        );
      }
      _isConfirming = false;
      if (!isDisposed) notifyListeners();
      return true;
    } catch (e) {
      _isConfirming = false;
      _errorMessage = PedidoConfirmacaoErro.mensagem(e);
      if (!isDisposed) notifyListeners();
      return null;
    }
  }

  Future<bool?> cancelarPedido() async {
    final status = statusAtual;
    if (status == 'cancelado' || status == 'concluido') return false;
    if (_isCancelling) return null;
    _isCancelling = true;
    _errorMessage = '';
    if (!isDisposed) notifyListeners();

    try {
      await _pedidoService.alterarStatusPedido(
        idPedido,
        _empresaService.idEmpresa,
        'cancelado',
      );
      if (_pedido != null) {
        _pedido = PedidoListagemModel(
          idPedido: _pedido!.idPedido,
          idEmpresa: _pedido!.idEmpresa,
          idCliente: _pedido!.idCliente,
          status: 'cancelado',
          total: _pedido!.total,
          volume: _pedido!.volume,
          createdAt: _pedido!.createdAt,
          pagamento: _pedido!.pagamento,
        );
      }
      _isCancelling = false;
      if (!isDisposed) notifyListeners();
      return true;
    } catch (e) {
      _isCancelling = false;
      _errorMessage = e is Exception
          ? e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '')
          : 'Erro ao cancelar pedido. Tente novamente.';
      if (!isDisposed) notifyListeners();
      return null;
    }
  }

  Future<int?> arquivarPedido() async {
    if (_isDeleting) return null;
    _isDeleting = true;
    if (!isDisposed) notifyListeners();

    try {
      final rows = await _pedidoService.arquivarPedido(
        idPedido,
        _empresaService.idEmpresa,
      );
      _isDeleting = false;
      if (!isDisposed) notifyListeners();
      return rows;
    } catch (_) {
      _isDeleting = false;
      _errorMessage = 'Erro ao excluir pedido. Tente novamente.';
      if (!isDisposed) notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    disposeProdutoBusca();
    disposeEdicao();
    super.dispose();
  }
}
