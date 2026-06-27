import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';

/// Formata preço para exibição na tela de detalhes.
String formatarPrecoDetalhe(double preco) {
  return preco.toStringAsFixed(2).replaceAll('.', ',');
}

/// ViewModel da tela de detalhes do produto.
/// Recebe o [idProduto]; busca os dados na API ao inicializar.
class ProdutoDetalhesViewModel extends BaseViewModel {
  bool _isLoading = true;
  String? _loadError;

  final int idProduto;
  final ProdutoService _produtoService;

  ProdutoModel? _produto;
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  final TextEditingController estoqueController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  ProdutoDetalhesViewModel(this.idProduto, this._produtoService) {
    _carregarProduto();
  }

  bool get isLoading => _isLoading;
  String? get loadError => _loadError;
  ProdutoModel? get produto => _produto;

  Future<void> _carregarProduto() async {
    _isLoading = true;
    _loadError = null;
    if (!isDisposed) notifyListeners();
    try {
      _produto = await _produtoService.buscarPorId(idProduto);
      if (_produto != null) {
        _preencherFormulario();
      } else {
        _loadError = 'Produto não encontrado.';
      }
      _isLoading = false;
      if (!isDisposed) notifyListeners();
    } catch (_) {
      _loadError = 'Erro ao carregar dados do produto.';
      _isLoading = false;
      if (!isDisposed) notifyListeners();
    }
  }

  void _preencherFormulario() {
    final p = _produto;
    if (p == null) return;
    nomeController.text = p.nome;
    precoController.text = 'R\$ ${formatarPrecoDetalhe(p.preco)}';
    estoqueController.text = p.estoqueAtual.toString();
    statusController.text = p.status;
  }

  Future<void> recarregar() => _carregarProduto();

  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    estoqueController.dispose();
    statusController.dispose();
    super.dispose();
  }
}
