import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/mixins/pedido_criar_itens_mixin.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';

/// Busca de produtos e fluxo de adição no formulário de criação de pedido.
mixin PedidoCriarProdutoBuscaMixin on ChangeNotifier, PedidoCriarItensMixin {
  ProdutoService get produtoService;

  bool _mostrandoAdicionarProduto = false;
  bool get mostrandoAdicionarProduto => _mostrandoAdicionarProduto;

  void mostrarSecaoAdicionarProduto() {
    _mostrandoAdicionarProduto = true;
    if (!isVmDisposed) notifyListeners();
  }

  final TextEditingController produtoQueryController = TextEditingController();
  List<ProdutoModel> _produtosBusca = [];
  List<ProdutoModel> get produtosBusca => List.unmodifiable(_produtosBusca);

  /// Lista completa de produtos (para a lista principal do modal). Não é filtrada pela busca.
  List<ProdutoModel> _todosProdutos = [];
  List<ProdutoModel> get todosProdutos => List.unmodifiable(_todosProdutos);

  bool _hasSearchedProduto = false;
  bool get hasSearchedProduto => _hasSearchedProduto;
  ViewState _stateBuscaProduto = ViewState.idle;
  ViewState get stateBuscaProduto => _stateBuscaProduto;
  String? _errorBuscaProduto;
  String? get errorBuscaProduto => _errorBuscaProduto;

  ProdutoModel? _produtoSelecionadoParaAdicionar;
  ProdutoModel? get produtoSelecionadoParaAdicionar =>
      _produtoSelecionadoParaAdicionar;

  final TextEditingController quantidadeAdicionarController =
      TextEditingController(text: '1');
  final TextEditingController produtoNomeDisplayController =
      TextEditingController();
  final TextEditingController produtoValorDisplayController =
      TextEditingController();
  final TextEditingController produtoTotalDisplayController =
      TextEditingController();

  static const Duration _debounceBuscaProduto = Duration(milliseconds: 400);
  Timer? _timerBuscaProduto;

  void initProdutoBuscaListeners() {
    quantidadeAdicionarController.addListener(_atualizarTotalAdicionarProduto);
  }

  void disposeProdutoBusca() {
    _timerBuscaProduto?.cancel();
    produtoQueryController.dispose();
    quantidadeAdicionarController.dispose();
    produtoNomeDisplayController.dispose();
    produtoValorDisplayController.dispose();
    produtoTotalDisplayController.dispose();
  }

  /// Ao clicar em um produto na busca: adiciona à lista com quantidade 1 ou soma 1 se já existir.
  /// Permite escolher vários produtos em sequência; depois o usuário ajusta quantidades na lista.
  void selecionarProdutoParaAdicionar(ProdutoModel p) {
    final idProduto = p.idProduto;
    final indexExistente = idProduto == null
        ? -1
        : itens.indexWhere((i) => i.produto.idProduto == idProduto);
    if (indexExistente >= 0) {
      final item = itens[indexExistente];
      atualizarQuantidadeItem(indexExistente, item.quantidade + 1);
    } else {
      adicionarItem(p, 1);
    }
  }

  void cancelarAdicionarProduto() {
    _produtoSelecionadoParaAdicionar = null;
    quantidadeAdicionarController.text = '1';
    produtoNomeDisplayController.clear();
    produtoValorDisplayController.clear();
    produtoTotalDisplayController.clear();
    if (!isVmDisposed) notifyListeners();
  }

  void _atualizarTotalAdicionarProduto() {
    final p = _produtoSelecionadoParaAdicionar;
    if (p == null) return;
    final qtd = int.tryParse(quantidadeAdicionarController.text) ?? 1;
    produtoTotalDisplayController.text = 'R\$ ${formatarPreco(p.preco * qtd)}';
    if (!isVmDisposed) notifyListeners();
  }

  /// Carrega todos os produtos (API sem q). Chamado ao clicar/focar na barra.
  Future<void> carregarTodosProdutos() async {
    _hasSearchedProduto = true;
    _errorBuscaProduto = null;
    _stateBuscaProduto = ViewState.loading;
    if (!isVmDisposed) notifyListeners();
    try {
      final lista = await produtoService.listar(
        status: null,
        q: null,
        includeDeleted: false,
      );
      _produtosBusca = lista;
      _todosProdutos = List.from(lista);
      _stateBuscaProduto = ViewState.success;
    } catch (_) {
      _stateBuscaProduto = ViewState.error;
      _errorBuscaProduto = 'Erro ao carregar. Tente novamente.';
    }
    if (!isVmDisposed) notifyListeners();
  }

  /// Busca produtos por nome (API com q). Chamado ao digitar (com debounce) ou submit.
  Future<void> buscarProdutos() async {
    final q = produtoQueryController.text.trim();
    if (q.isEmpty) {
      await carregarTodosProdutos();
      return;
    }
    _hasSearchedProduto = true;
    _errorBuscaProduto = null;
    _stateBuscaProduto = ViewState.loading;
    if (!isVmDisposed) notifyListeners();
    try {
      _produtosBusca = await produtoService.listar(
        status: null,
        q: q,
        includeDeleted: false,
      );
      _stateBuscaProduto = ViewState.success;
    } catch (_) {
      _stateBuscaProduto = ViewState.error;
      _errorBuscaProduto = 'Erro ao buscar. Tente novamente.';
    }
    if (!isVmDisposed) notifyListeners();
  }

  /// Agenda busca ao parar de digitar (debounce). Chamado por onChanged da barra de produto.
  void agendarBuscaProduto() {
    _timerBuscaProduto?.cancel();
    _timerBuscaProduto = Timer(_debounceBuscaProduto, () {
      _timerBuscaProduto = null;
      if (!isVmDisposed) buscarProdutos();
    });
  }

  /// Limpa busca de produtos (ex.: ao abrir o modal de seleção). Mantém todosProdutos para a lista principal.
  void limparBuscaProduto() {
    produtoQueryController.clear();
    _produtosBusca = [];
    if (!isVmDisposed) notifyListeners();
  }

  void confirmarAdicionarProduto() {
    final p = _produtoSelecionadoParaAdicionar;
    if (p == null) return;
    final qtdStr = quantidadeAdicionarController.text.trim();
    final qtd = int.tryParse(qtdStr) ?? 0;
    if (qtd < 1) return;
    adicionarItem(p, qtd);
    _produtoSelecionadoParaAdicionar = null;
    quantidadeAdicionarController.text = '1';
    if (!isVmDisposed) notifyListeners();
  }
}
