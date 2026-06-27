import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';

/// Busca e seleção de produtos (modal de adicionar) reutilizável no detalhe do pedido.
mixin PedidoProdutoBuscaMixin on ChangeNotifier {
  bool get isVmDisposed;
  ProdutoService get produtoService;

  final TextEditingController produtoQueryController = TextEditingController();
  List<ProdutoModel> _produtosBusca = [];
  List<ProdutoModel> get produtosBusca => List.unmodifiable(_produtosBusca);

  List<ProdutoModel> get todosProdutos => List.unmodifiable(_produtosBusca);

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

  Timer? _timerBuscaProduto;
  static const Duration _debounceBuscaProduto = Duration(milliseconds: 400);

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

  void selecionarProdutoParaAdicionar(ProdutoModel p) {
    _produtoSelecionadoParaAdicionar = p;
    _produtosBusca = [];
    _hasSearchedProduto = false;
    produtoQueryController.clear();
    quantidadeAdicionarController.text = '1';
    produtoNomeDisplayController.text = p.nome;
    produtoValorDisplayController.text = 'R\$ ${formatarPreco(p.preco)}';
    produtoTotalDisplayController.text = 'R\$ ${formatarPreco(p.preco)}';
    if (!isVmDisposed) notifyListeners();
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
    produtoTotalDisplayController.text =
        'R\$ ${formatarPreco(p.preco * qtd)}';
    if (!isVmDisposed) notifyListeners();
  }

  Future<void> carregarTodosProdutos() async {
    _hasSearchedProduto = true;
    _errorBuscaProduto = null;
    _stateBuscaProduto = ViewState.loading;
    if (!isVmDisposed) notifyListeners();
    try {
      _produtosBusca = await produtoService.listar(
        status: null,
        q: null,
        includeDeleted: false,
      );
      _stateBuscaProduto = ViewState.success;
    } catch (_) {
      _stateBuscaProduto = ViewState.error;
      _errorBuscaProduto = 'Erro ao carregar. Tente novamente.';
    }
    if (!isVmDisposed) notifyListeners();
  }

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

  void agendarBuscaProduto() {
    _timerBuscaProduto?.cancel();
    _timerBuscaProduto = Timer(_debounceBuscaProduto, () {
      _timerBuscaProduto = null;
      if (!isVmDisposed) buscarProdutos();
    });
  }
}
