import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';
import 'package:flutter/services.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_criar_extra.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/clientes/utils/cliente_form_utils.dart';
import 'package:erp_alianca_dev/features/clientes/utils/cliente_validator.dart';
import 'package:erp_alianca_dev/shared/models/cnpj_consulta_model.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/utils/form_utils.dart';

/// ViewModel do formulário de criação de cliente.
class ClienteCriarViewModel extends BaseViewModel {
  bool _isLoading = false;
  String? _errorMessage;

  final ClienteService _clienteService;
  final EmpresaService _empresaService;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// true = CPF, false = CNPJ
  bool _isCpf = true;
  bool get isCpf => _isCpf;
  set isCpf(bool value) {
    _isCpf = value;
    documentController.clear();
    if (!isDisposed) notifyListeners();
  }

  final TextEditingController documentController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController nomeEmpresaController = TextEditingController();
  final TextEditingController nomeResponsavelController = TextEditingController();
  final TextEditingController ddController = TextEditingController();
  final TextEditingController telefoneNumeroController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController logradouroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();

  ClienteCriarViewModel(this._clienteService, this._empresaService) {
    _addListeners();
  }

  void _addListeners() {
    void notify() {
      if (!isDisposed) notifyListeners();
    }
    documentController.addListener(notify);
    nomeController.addListener(notify);
    nomeEmpresaController.addListener(notify);
    nomeResponsavelController.addListener(notify);
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

  String _status = 'Ativo';
  String get status => _status;

  bool _abrirPedidoAposSalvar = false;
  String _rotaVoltar = AppRoutes.clientes;
  ClienteModel? _clienteParaPedido;

  bool get abrirPedidoAposSalvar => _abrirPedidoAposSalvar;
  String get rotaVoltar => _rotaVoltar;
  bool get veioDeConsultaCnpj =>
      _rotaVoltar == AppRoutes.clientesConsultaCnpj;

  /// Retorna e limpa o cliente localizado após salvar (fluxo pedido via CNPJ).
  ClienteModel? takeClienteParaPedido() {
    final cliente = _clienteParaPedido;
    _clienteParaPedido = null;
    return cliente;
  }

  void aplicarExtra(ClienteCriarExtra extra) {
    _abrirPedidoAposSalvar = extra.abrirPedidoAposSalvar;
    _rotaVoltar = extra.rotaVoltar;
    preencherComConsultaCnpj(extra.consultaCnpj);
  }

  /// Preenche o formulário com dados retornados da consulta de CNPJ.
  void preencherComConsultaCnpj(CnpjConsultaModel dados) {
    _isCpf = false;
    documentController.text =
        ClienteModel.documentoMascaradoParaCampo('cnpj', dados.cnpj);
    nomeController.text = dados.razaoSocial;
    nomeEmpresaController.text = dados.nomeFantasia?.trim() ?? '';
    _preencherTelefone(dados.telefone);
    emailController.text = dados.email;
    cepController.text = _formatarCep(dados.cep);
    logradouroController.text = dados.logradouro;
    numeroController.text = dados.numero;
    bairroController.text = dados.bairro;
    cidadeController.text = dados.cidade;
    estadoController.text = dados.estado.toUpperCase();
    _status = 'Ativo';
    _errorMessage = null;
    notifyListeners();
  }

  void _preencherTelefone(String telefone) {
    final digits = telefone.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 2) {
      ddController.text = digits;
      telefoneNumeroController.clear();
      return;
    }
    ddController.text = digits.substring(0, 2);
    telefoneNumeroController.text = digits.substring(2);
  }

  static String _formatarCep(String cep) {
    final digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 5) return digits;
    return '${digits.substring(0, 5)}-${digits.substring(5)}';
  }

  /// Indica se há dados de cliente no clipboard (após copiar neste formulário).
  bool _temClienteCopiado = false;
  bool get temClienteCopiado => _temClienteCopiado;

  set status(String value) {
    _status = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Documento apenas dígitos (CPF 11 ou CNPJ 14).
  String get _documentoDigits =>
      FormUtils.safeText(documentController).replaceAll(RegExp(r'\D'), '');

  /// Exibir campo "Nome da empresa" quando cpf_cnpj tiver 14 dígitos (CNPJ).
  bool get deveExibirCampoNomeEmpresa => _documentoDigits.length == 14;

  /// Indica se há dados preenchidos (alterações não salvas).
  bool get hasChanges {
    if (FormUtils.safeText(documentController).isNotEmpty) return true;
    if (FormUtils.safeText(nomeController).isNotEmpty) return true;
    if (FormUtils.safeText(nomeEmpresaController).isNotEmpty) return true;
    if (FormUtils.safeText(nomeResponsavelController).isNotEmpty) return true;
    if (FormUtils.safeDigits(ddController).isNotEmpty) return true;
    if (FormUtils.safeDigits(telefoneNumeroController).isNotEmpty) return true;
    if (FormUtils.safeText(emailController).isNotEmpty) return true;
    if (FormUtils.safeText(cepController).isNotEmpty) return true;
    if (FormUtils.safeText(logradouroController).isNotEmpty) return true;
    if (FormUtils.safeText(numeroController).isNotEmpty) return true;
    if (FormUtils.safeText(bairroController).isNotEmpty) return true;
    if (FormUtils.safeText(cidadeController).isNotEmpty) return true;
    if (FormUtils.safeText(estadoController).isNotEmpty) return true;
    if (_status != 'Ativo') return true;
    return false;
  }

  /// Indica se o formulário está válido. Apenas o nome é obrigatório.
  bool get isValid =>
      ClienteValidator.isValidCriar(_isCpf, nomeController.text);

  /// Lista de labels dos campos obrigatórios que faltam. Apenas o nome é obrigatório.
  List<String> get camposFaltantes =>
      ClienteValidator.camposFaltantesCriar(_isCpf, nomeController.text);

  static String? _trimEmptyToNull(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  @override
  void dispose() {
    documentController.dispose();
    nomeController.dispose();
    nomeEmpresaController.dispose();
    nomeResponsavelController.dispose();
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

  /// Telefone completo (DD + número) para o model. Sempre usa leitura segura (nunca null).
  String get telefoneCompleto =>
      '${FormUtils.safeDigits(ddController)}${FormUtils.safeDigits(telefoneNumeroController)}';

  /// Chave usada no clipboard para identificar dados do formulário de cliente.
  static const String _clipboardKey = 'erp_alianca_dev_cliente_form';

  Map<String, dynamic> _formToJson() {
    return {
      'isCpf': _isCpf,
      'documento': FormUtils.safeText(documentController),
      'nome': FormUtils.safeText(nomeController),
      'nomeEmpresa': FormUtils.safeText(nomeEmpresaController),
      'nomeResponsavel': FormUtils.safeText(nomeResponsavelController),
      'dd': FormUtils.safeDigits(ddController),
      'telefoneNumero': FormUtils.safeDigits(telefoneNumeroController),
      'email': FormUtils.safeText(emailController),
      'cep': FormUtils.safeText(cepController),
      'logradouro': FormUtils.safeText(logradouroController),
      'numero': FormUtils.safeText(numeroController),
      'bairro': FormUtils.safeText(bairroController),
      'cidade': FormUtils.safeText(cidadeController),
      'estado': FormUtils.safeText(estadoController),
      'status': _status,
    };
  }

  /// Copia os dados atuais do formulário para o clipboard (JSON).
  void copiarFormulario() {
    final json = jsonEncode(_formToJson());
    Clipboard.setData(ClipboardData(text: '$_clipboardKey|$json'));
    _temClienteCopiado = true;
    notifyListeners();
  }

  /// Cola dados do clipboard no formulário. Retorna true se colou com sucesso.
  Future<bool> colarFormulario() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return false;
    final idx = text.indexOf('|');
    if (idx < 0 || text.substring(0, idx) != _clipboardKey) return false;
    try {
      final map = jsonDecode(text.substring(idx + 1)) as Map<String, dynamic>;
      _isCpf = map['isCpf'] as bool? ?? true;
      documentController.text = map['documento'] as String? ?? '';
      nomeController.text = map['nome'] as String? ?? '';
      nomeEmpresaController.text = map['nomeEmpresa'] as String? ?? '';
      nomeResponsavelController.text = map['nomeResponsavel'] as String? ?? '';
      ddController.text = map['dd'] as String? ?? '';
      telefoneNumeroController.text = map['telefoneNumero'] as String? ?? '';
      emailController.text = map['email'] as String? ?? '';
      cepController.text = map['cep'] as String? ?? '';
      logradouroController.text = map['logradouro'] as String? ?? '';
      numeroController.text = map['numero'] as String? ?? '';
      bairroController.text = map['bairro'] as String? ?? '';
      cidadeController.text = map['cidade'] as String? ?? '';
      estadoController.text = map['estado'] as String? ?? '';
      final s = map['status'] as String?;
      if (s == 'Ativo' || s == 'Inativo') _status = s!;
      _temClienteCopiado = false;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Limpa todos os campos do formulário (ex.: após salvar com sucesso).
  void limparFormulario() {
    documentController.clear();
    nomeController.clear();
    nomeEmpresaController.clear();
    nomeResponsavelController.clear();
    ddController.clear();
    telefoneNumeroController.clear();
    emailController.clear();
    cepController.clear();
    logradouroController.clear();
    numeroController.clear();
    bairroController.clear();
    cidadeController.clear();
    estadoController.clear();
    _status = 'Ativo';
    _errorMessage = null;
    _temClienteCopiado = false;
    notifyListeners();
  }

  /// Salva o cliente na API. Retorna true se salvou com sucesso.
  Future<bool> salvar() async {
    _errorMessage = null;
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return false;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final values = ClienteFormValues(
        tipoDocumento: _isCpf ? 'cpf' : 'cnpj',
        documentoDigits: _documentoDigits,
        nome: FormUtils.safeText(nomeController),
        nomeEmpresa: _trimEmptyToNull(FormUtils.safeText(nomeEmpresaController)),
        nomeResponsavel: _isCpf ? null : _trimEmptyToNull(FormUtils.safeText(nomeResponsavelController)),
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
      final model = values.toModel(_empresaService.idEmpresa);
      final documentoSalvo = _documentoDigits;
      final buscarParaPedido = _abrirPedidoAposSalvar;
      await _clienteService.criarCliente(model);
      if (buscarParaPedido && documentoSalvo.isNotEmpty) {
        _clienteParaPedido =
            await _buscarClientePorDocumento(documentoSalvo);
      }
      _abrirPedidoAposSalvar = false;
      limparFormulario();
      _isLoading = false;
      if (!isDisposed) notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      if (!isDisposed) notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Erro ao salvar cliente. Tente novamente.';
      _isLoading = false;
      if (!isDisposed) notifyListeners();
      return false;
    }
  }

  Future<ClienteModel?> _buscarClientePorDocumento(String documento) async {
    try {
      final clientes = await _clienteService.listarClientes(status: 'ativa');
      for (final cliente in clientes) {
        if (cliente.documento.replaceAll(RegExp(r'\D'), '') == documento) {
          return cliente;
        }
      }
    } catch (e) {
      BaseViewModel.logFailure(e, tag: 'ClienteCriar.buscarPorDocumento');
    }
    return null;
  }
}
