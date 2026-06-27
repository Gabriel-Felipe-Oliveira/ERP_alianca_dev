import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/clientes/utils/cliente_form_utils.dart';
import 'package:erp_alianca_dev/features/clientes/utils/cliente_validator.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/utils/form_utils.dart';

/// ViewModel da tela de detalhes/edição de cliente.
/// Recebe apenas o [idCliente]; busca os dados na API ao inicializar.
class ClienteEditarViewModel extends BaseViewModel {
  bool _isLoading = true;
  bool _isExcluindo = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _loadError;

  final int idCliente;
  final ClienteService _clienteService;
  final EmpresaService _empresaService;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ClienteModel? _cliente;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController nomeEmpresaController = TextEditingController();
  final TextEditingController documentController = TextEditingController();
  final TextEditingController ddController = TextEditingController();
  final TextEditingController telefoneNumeroController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController logradouroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();

  ClienteEditarViewModel(this.idCliente, this._clienteService, this._empresaService) {
    _addListeners();
    _carregarCliente();
  }

  void _addListeners() {
    void notify() {
      if (!isDisposed) notifyListeners();
    }

    nomeController.addListener(notify);
    nomeEmpresaController.addListener(notify);
    documentController.addListener(notify);
    ddController.addListener(notify);
    telefoneNumeroController.addListener(notify);
    emailController.addListener(notify);
    cepController.addListener(notify);
    logradouroController.addListener(notify);
    numeroController.addListener(notify);
    bairroController.addListener(notify);
    cidadeController.addListener(notify);
    estadoController.addListener(notify);
  }

  Future<void> _carregarCliente() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();
    try {
      _cliente = await _clienteService.buscarClientePorId(idCliente);
      _preencherFormulario();
      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _loadError = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _loadError = 'Erro ao carregar dados do cliente.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tenta recarregar o cliente (ex.: após erro de rede).
  Future<void> recarregar() => _carregarCliente();

  /// Recarrega sem mostrar loading (ex.: após salvar). Mantém o formulário visível.
  Future<void> _recarregarSilencioso() async {
    try {
      _cliente = await _clienteService.buscarClientePorId(idCliente);
      _preencherFormulario();
      if (!isDisposed) notifyListeners();
    } catch (_) {
      // Mantém os dados atuais; falha silenciosa no reload pós-salvar.
      if (!isDisposed) notifyListeners();
    }
  }

  void _preencherFormulario() {
    final c = _cliente;
    if (c == null) return;
    nomeController.text = c.nome;
    nomeEmpresaController.text = c.nomeEmpresa ?? '';
    documentController.text = ClienteModel.documentoMascaradoParaCampo(c.tipoDocumento, c.documento);
    emailController.text = c.email;
    cepController.text = c.cep;
    logradouroController.text = c.logradouro;
    numeroController.text = c.numero;
    bairroController.text = c.bairro;
    cidadeController.text = c.cidade;
    estadoController.text = c.estado;
    _status = c.status;

    final tel = c.telefone.replaceAll(RegExp(r'\D'), '');
    if (tel.length >= 2) {
      ddController.text = tel.substring(0, 2);
      telefoneNumeroController.text = tel.length > 2 ? tel.substring(2) : '';
    } else {
      ddController.text = '';
      telefoneNumeroController.text = tel;
    }
  }

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  String _status = 'Ativo';
  String get status => _status;

  set status(String value) {
    _status = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isExcluindo => _isExcluindo;
  String? get errorMessage => _errorMessage;
  String? get loadError => _loadError;
  ClienteModel? get cliente => _cliente;

  // --- Campos modificados (comparação com o valor original) ---

  String get _ddOriginal {
    final tel = _cliente?.telefone.replaceAll(RegExp(r'\D'), '') ?? '';
    return tel.length >= 2 ? tel.substring(0, 2) : '';
  }

  String get _numeroOriginal {
    final tel = _cliente?.telefone.replaceAll(RegExp(r'\D'), '') ?? '';
    return tel.length > 2 ? tel.substring(2) : tel;
  }

  bool get nomeModificado => nomeController.text != (_cliente?.nome ?? '');
  bool get nomeEmpresaModificado =>
      nomeEmpresaController.text != (_cliente?.nomeEmpresa ?? '');
  bool get documentModificado =>
      documentController.text.replaceAll(RegExp(r'\D'), '') != (_cliente?.documento ?? '');
  bool get ddModificado => ddController.text != _ddOriginal;
  bool get telefoneNumeroModificado => telefoneNumeroController.text != _numeroOriginal;
  bool get emailModificado => emailController.text != (_cliente?.email ?? '');
  bool get cepModificado => cepController.text != (_cliente?.cep ?? '');
  bool get logradouroModificado => logradouroController.text != (_cliente?.logradouro ?? '');
  bool get numeroModificado => numeroController.text != (_cliente?.numero ?? '');
  bool get bairroModificado => bairroController.text != (_cliente?.bairro ?? '');
  bool get cidadeModificado => cidadeController.text != (_cliente?.cidade ?? '');
  bool get estadoModificado => estadoController.text != (_cliente?.estado ?? '');
  bool get statusModificado => _status != (_cliente?.status ?? 'Ativo');

  void ativarEdicao() {
    _isEditing = true;
    _errorMessage = null;
    if (!isDisposed) notifyListeners();
  }

  void cancelarEdicao() {
    _isEditing = false;
    _errorMessage = null;
    _preencherFormulario();
    if (!isDisposed) notifyListeners();
  }

  String get telefoneCompleto =>
      '${FormUtils.safeDigits(ddController)}${FormUtils.safeDigits(telefoneNumeroController)}';

  bool get isValid => ClienteValidator.isValidEditar(
        nome: nomeController.text,
        dd: ddController.text,
        telefoneNumero: telefoneNumeroController.text,
        email: emailController.text,
        logradouro: logradouroController.text,
        numero: numeroController.text,
        cep: cepController.text,
        bairro: bairroController.text,
        cidade: cidadeController.text,
        estado: estadoController.text,
      );

  @override
  void dispose() {
    nomeController.dispose();
    nomeEmpresaController.dispose();
    documentController.dispose();
    ddController.dispose();
    telefoneNumeroController.dispose();
    emailController.dispose();
    cepController.dispose();
    logradouroController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    super.dispose();
  }

  /// Atualiza o cliente na API (PUT). Retorna true se sucesso.
  Future<bool> salvar() async {
    final c = _cliente;
    if (c == null || c.id == null) return false;
    _errorMessage = null;
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return false;
    }
    _isSaving = true;
    notifyListeners();
    try {
      final values = ClienteFormValues(
        tipoDocumento: c.tipoDocumento,
        documentoDigits: FormUtils.safeText(documentController).replaceAll(RegExp(r'\D'), ''),
        nome: FormUtils.safeText(nomeController),
        nomeEmpresa: _trimEmptyToNull(FormUtils.safeText(nomeEmpresaController)),
        nomeResponsavel: null,
        telefone: telefoneCompleto,
        email: FormUtils.safeText(emailController),
        cep: FormUtils.safeText(cepController),
        logradouro: FormUtils.safeText(logradouroController),
        numero: FormUtils.safeText(numeroController),
        bairro: FormUtils.safeText(bairroController),
        cidade: FormUtils.safeText(cidadeController),
        estado: FormUtils.safeText(estadoController),
        status: _status,
      );
      final model = values.toModel(
        _empresaService.idEmpresa,
        id: c.id,
        nomeResponsavelOverride: c.nomeResponsavel,
      );
      await _clienteService.atualizarCliente(model);
      await _recarregarSilencioso();
      _isEditing = false;
      _isSaving = false;
      if (!isDisposed) notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isSaving = false;
      if (!isDisposed) notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Erro ao atualizar cliente. Tente novamente.';
      _isSaving = false;
      if (!isDisposed) notifyListeners();
      return false;
    }
  }

  static String? _trimEmptyToNull(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  /// Exclui (arquiva) o cliente na API (DELETE). Retorna true se sucesso.
  Future<bool> excluir() async {
    final c = _cliente;
    if (c == null || c.id == null) return false;
    _errorMessage = null;
    _isExcluindo = true;
    notifyListeners();
    try {
      await _clienteService.excluirCliente(c.id!, _empresaService.idEmpresa);
      _isExcluindo = false;
      if (!isDisposed) notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isExcluindo = false;
      if (!isDisposed) notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Erro ao excluir cliente. Tente novamente.';
      _isExcluindo = false;
      if (!isDisposed) notifyListeners();
      return false;
    }
  }
}
