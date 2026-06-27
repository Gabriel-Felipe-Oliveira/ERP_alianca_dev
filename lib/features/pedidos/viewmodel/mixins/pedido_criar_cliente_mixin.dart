import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/utils/cliente_formatters.dart';

/// Busca, seleção e controllers de cliente no formulário de criação de pedido.
mixin PedidoCriarClienteMixin on ChangeNotifier {
  bool get isVmDisposed;
  ClienteService get clienteService;

  ClienteModel? _clienteSelecionado;
  ClienteModel? get clienteSelecionado => _clienteSelecionado;

  final TextEditingController clienteQueryController = TextEditingController();
  final TextEditingController clienteIdDisplayController =
      TextEditingController();
  final TextEditingController clienteNomeDisplayController =
      TextEditingController();
  final TextEditingController clienteTelefoneDisplayController =
      TextEditingController();
  final TextEditingController clienteEnderecoDisplayController =
      TextEditingController();

  List<ClienteModel> _clientesBusca = [];
  bool _hasSearchedCliente = false;
  ViewState _stateBuscaCliente = ViewState.idle;

  List<ClienteModel> get clientesBusca => List.unmodifiable(_clientesBusca);
  bool get hasSearchedCliente => _hasSearchedCliente;
  ViewState get stateBuscaCliente => _stateBuscaCliente;
  String? get errorBuscaCliente =>
      _stateBuscaCliente == ViewState.error
          ? 'Erro ao buscar. Tente novamente.'
          : null;

  static const Duration _debounceBuscaCliente = Duration(milliseconds: 400);
  Timer? _timerBuscaCliente;

  void disposeCliente() {
    _timerBuscaCliente?.cancel();
    clienteQueryController.dispose();
    clienteIdDisplayController.dispose();
    clienteNomeDisplayController.dispose();
    clienteTelefoneDisplayController.dispose();
    clienteEnderecoDisplayController.dispose();
  }

  void _limparBuscaCliente() {
    _clientesBusca = [];
    _hasSearchedCliente = false;
    _stateBuscaCliente = ViewState.idle;
  }

  void selecionarCliente(ClienteModel c) {
    _clienteSelecionado = c;
    clienteIdDisplayController.text = c.id?.toString() ?? '';
    clienteNomeDisplayController.text = c.nome;
    clienteTelefoneDisplayController.text = c.telefone;
    clienteEnderecoDisplayController.text = formatarEnderecoDisplay(c);
    _limparBuscaCliente();
    clienteQueryController.clear();
    if (!isVmDisposed) notifyListeners();
  }

  void limparCliente() {
    _clienteSelecionado = null;
    clienteIdDisplayController.clear();
    clienteNomeDisplayController.clear();
    clienteTelefoneDisplayController.clear();
    clienteEnderecoDisplayController.clear();
    if (!isVmDisposed) notifyListeners();
  }

  /// Pré-seleciona o cliente (ex.: ao abrir a tela a partir dos detalhes do cliente).
  void inicializarComCliente(ClienteModel c) {
    selecionarCliente(c);
  }

  /// Prepara o modal de seleção: limpa a busca anterior e carrega a lista.
  Future<void> iniciarModalSelecaoCliente() async {
    _timerBuscaCliente?.cancel();
    _timerBuscaCliente = null;
    clienteQueryController.clear();
    await carregarListaClientes();
  }

  /// Carrega todos os clientes ativos (API sem q).
  Future<void> carregarListaClientes() async {
    if (isVmDisposed) return;
    _hasSearchedCliente = true;
    _stateBuscaCliente = ViewState.loading;
    if (!isVmDisposed) notifyListeners();
    try {
      _clientesBusca = await clienteService.listarClientes(
        status: 'ativa',
        includeDeleted: false,
      );
      if (isVmDisposed) return;
      _stateBuscaCliente = ViewState.success;
    } catch (_) {
      if (isVmDisposed) return;
      _stateBuscaCliente = ViewState.error;
    }
    if (!isVmDisposed) notifyListeners();
  }

  /// Busca clientes por nome (API com q). Chamado ao digitar e dar submit na barra.
  Future<void> buscarClientesPorNome() async {
    if (isVmDisposed) return;
    final q = clienteQueryController.text.trim();
    if (q.isEmpty) {
      await carregarListaClientes();
      return;
    }
    _hasSearchedCliente = true;
    _stateBuscaCliente = ViewState.loading;
    if (!isVmDisposed) notifyListeners();
    try {
      _clientesBusca = await clienteService.listarClientes(
        status: 'ativa',
        q: q,
        includeDeleted: false,
      );
      if (isVmDisposed) return;
      _stateBuscaCliente = ViewState.success;
    } catch (_) {
      if (isVmDisposed) return;
      _stateBuscaCliente = ViewState.error;
    }
    if (!isVmDisposed) notifyListeners();
  }

  /// Agenda busca ao parar de digitar (debounce). Chamado por onChanged da barra.
  void agendarBuscaCliente() {
    _timerBuscaCliente?.cancel();
    _timerBuscaCliente = Timer(_debounceBuscaCliente, () {
      _timerBuscaCliente = null;
      if (!isVmDisposed) buscarClientesPorNome();
    });
  }
}
