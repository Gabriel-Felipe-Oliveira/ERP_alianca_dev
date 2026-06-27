import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/utils/app_validators.dart';
import 'package:erp_alianca_dev/shared/utils/form_utils.dart';

/// ViewModel do formulário de criação de produto.
class ProdutoCriarViewModel extends BaseViewModel {
  bool _isLoading = false;
  String? _errorMessage;

  final ProdutoService _produtoService;
  final EmpresaService _empresaService;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController precoController = TextEditingController(text: '0,00');
  final TextEditingController estoqueAtualController = TextEditingController();

  ProdutoCriarViewModel(this._produtoService, this._empresaService) {
    _addListeners();
  }

  void _addListeners() {
    void notify() {
      if (!isDisposed) notifyListeners();
    }
    nomeController.addListener(notify);
    precoController.addListener(notify);
    estoqueAtualController.addListener(notify);
  }

  String _status = 'ativo';
  String get status => _status;
  set status(String value) {
    _status = value;
    if (!isDisposed) notifyListeners();
  }

  static const List<String> statusOpcoes = ['ativo', 'inativo'];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isValid {
    if (AppValidators.obrigatorio(nomeController.text, 'Nome') != null) return false;
    if (AppValidators.preco(precoController.text) != null) return false;
    final estoque = estoqueAtualController.text.trim();
    if (estoque.isNotEmpty &&
        AppValidators.inteiroNaoNegativo(estoque, 'Estoque') != null) {
      return false;
    }
    return true;
  }

  /// Lista de labels dos campos que ainda faltam preencher ou estão inválidos.
  List<String> get camposFaltantes {
    final faltantes = <String>[];
    if (AppValidators.obrigatorio(nomeController.text, 'Nome') != null) {
      faltantes.add('Nome');
    }
    if (AppValidators.preco(precoController.text) != null) {
      faltantes.add('Preço');
    }
    final estoque = estoqueAtualController.text.trim();
    if (estoque.isNotEmpty &&
        AppValidators.inteiroNaoNegativo(estoque, 'Estoque') != null) {
      faltantes.add('Estoque atual');
    }
    return faltantes;
  }

  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    estoqueAtualController.dispose();
    super.dispose();
  }

  void limparFormulario() {
    nomeController.clear();
    precoController.text = '0,00';
    estoqueAtualController.clear();
    _status = 'ativo';
    _errorMessage = null;
    if (!isDisposed) notifyListeners();
  }

  /// Salva o produto na API. Retorna true se criado com sucesso.
  Future<bool> salvar() async {
    _errorMessage = null;
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return false;
    }
    _isLoading = true;
    if (!isDisposed) notifyListeners();
    try {
      // Remove a máscara de moeda (ex.: "10,01" → 10.01) — a API espera número, não string
      final precoStr = FormUtils.safeText(precoController).replaceAll(',', '.');
      final preco = double.tryParse(precoStr) ?? 0.0;
      final estoqueStr = FormUtils.safeText(estoqueAtualController);
      final estoque = estoqueStr.isEmpty
          ? 0
          : (int.tryParse(estoqueStr) ?? 0);

      final produto = ProdutoModel(
        idEmpresa: _empresaService.idEmpresa,
        nome: FormUtils.safeText(nomeController),
        preco: preco,
        estoqueAtual: estoque,
        status: _status,
      );
      await _produtoService.criar(produto);
      limparFormulario();
      _isLoading = false;
      if (!isDisposed) notifyListeners();
      return true;
    } on AppException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      if (!isDisposed) notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Erro ao criar produto. Tente novamente.';
      if (!isDisposed) notifyListeners();
      return false;
    }
  }
}
