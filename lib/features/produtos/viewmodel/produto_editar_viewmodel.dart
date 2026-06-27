import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/utils/app_validators.dart';
import 'package:erp_alianca_dev/shared/utils/form_utils.dart';

/// Formata preço para exibição na tela de detalhes.
String formatarPrecoDetalhe(double preco) {
  return preco.toStringAsFixed(2).replaceAll('.', ',');
}

/// ViewModel da tela de detalhes/edição de produto.
/// Recebe apenas o [idProduto]; busca os dados na API ao inicializar.
class ProdutoEditarViewModel extends BaseViewModel {
  bool _isLoading = true;
  bool _isExcluindo = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _loadError;

  final int idProduto;
  final ProdutoService _produtoService;
  final EmpresaService _empresaService;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ProdutoModel? _produto;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  final TextEditingController estoqueController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  ProdutoEditarViewModel(this.idProduto, this._produtoService, this._empresaService) {
    _addListeners();
    _carregarProduto();
  }

  void _addListeners() {
    void notify() {
      if (!isDisposed) notifyListeners();
    }
    nomeController.addListener(notify);
    precoController.addListener(notify);
    estoqueController.addListener(notify);
  }

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
    _status = p.status;
  }

  Future<void> recarregar() => _carregarProduto();

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  String _status = 'ativo';
  String get status => _status;
  set status(String value) {
    _status = value;
    if (!isDisposed) notifyListeners();
  }

  static const List<String> statusOpcoes = ['ativo', 'inativo'];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isExcluindo => _isExcluindo;
  String? get errorMessage => _errorMessage;
  String? get loadError => _loadError;
  ProdutoModel? get produto => _produto;

  bool get nomeModificado => nomeController.text != (_produto?.nome ?? '');
  bool get precoModificado {
    final precoStr = FormUtils.safeText(precoController)
        .replaceAll(RegExp(r'[^\d,]'), '')
        .replaceAll(',', '.');
    final preco = double.tryParse(precoStr) ?? 0.0;
    return (preco - (_produto?.preco ?? 0)).abs() > 0.001;
  }
  bool get statusModificado => _status != (_produto?.status ?? 'ativo');

  void ativarEdicao() {
    _isEditing = true;
    _errorMessage = null;
    // Ao ativar edição, preenche preço sem "R$" para edição
    final p = _produto;
    if (p != null) {
      precoController.text = formatarPrecoDetalhe(p.preco);
    }
    if (!isDisposed) notifyListeners();
  }

  void cancelarEdicao() {
    _isEditing = false;
    _errorMessage = null;
    _preencherFormulario();
    if (!isDisposed) notifyListeners();
  }

  bool get isValid {
    if (AppValidators.obrigatorio(nomeController.text, 'Nome') != null) {
      return false;
    }
    final precoStr = FormUtils.safeText(precoController)
        .replaceAll(RegExp(r'[^\d,]'), '')
        .replaceAll(',', '.');
    if (precoStr.isEmpty || double.tryParse(precoStr) == null) {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    estoqueController.dispose();
    statusController.dispose();
    super.dispose();
  }

  /// Atualiza o produto na API (PUT). Retorna true se sucesso.
  /// Estoque não é alterado por esta API (faz parte do stock); enviamos o valor original.
  Future<bool> salvar() async {
    final p = _produto;
    if (p == null || p.idProduto == null) return false;
    _errorMessage = null;
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return false;
    }
    _isSaving = true;
    if (!isDisposed) notifyListeners();
    try {
      final nome = FormUtils.safeText(nomeController);
      final precoStr = FormUtils.safeText(precoController)
          .replaceAll(RegExp(r'[^\d,]'), '')
          .replaceAll(',', '.');
      final preco = double.tryParse(precoStr) ?? 0.0;
      // Estoque/quantidade é controlado pelo stock na API; não alteramos aqui.
      final estoqueAtual = p.estoqueAtual;

      final model = ProdutoModel(
        idProduto: p.idProduto,
        idEmpresa: _empresaService.idEmpresa,
        nome: nome,
        preco: preco,
        estoqueAtual: estoqueAtual,
        status: _status,
      );
      await _produtoService.atualizar(model);
      _isSaving = false;
      _isEditing = false;
      await _carregarProduto();
      if (!isDisposed) notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isSaving = false;
      if (!isDisposed) notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Erro ao atualizar produto. Tente novamente.';
      _isSaving = false;
      if (!isDisposed) notifyListeners();
      return false;
    }
  }

  /// Exclui (arquiva) o produto na API (DELETE). Retorna true se sucesso.
  Future<bool> excluir() async {
    final p = _produto;
    if (p == null || p.idProduto == null) return false;
    _errorMessage = null;
    _isExcluindo = true;
    if (!isDisposed) notifyListeners();
    try {
      await _produtoService.arquivar(p.idProduto!, _empresaService.idEmpresa);
      _isExcluindo = false;
      if (!isDisposed) notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isExcluindo = false;
      if (!isDisposed) notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Erro ao excluir produto. Tente novamente.';
      _isExcluindo = false;
      if (!isDisposed) notifyListeners();
      return false;
    }
  }
}
