import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';
import 'package:erp_alianca_dev/shared/utils/app_validators.dart';

/// Status usado para filtrar pedidos disponíveis para o romaneio (Pronto para Entrega).
const String kStatusProntoEntrega = 'confirmado';
const String kStatusPedidoOrganizado = 'organizado';

/// ViewModel da tela de criação de romaneio.
/// Controla tipo de motorista, dados logísticos, data de criação, pedidos e criação.
/// Toda validação fica no ViewModel.
class RomaneioCriarViewModel extends BaseViewModel {
  bool _isLoading = false;
  bool _isLoadingPedidos = true;
  String? _errorMessage;

  final PedidoService _pedidoService;
  final RomaneioService _romaneioService;
  final EmpresaService _empresaService;
  final ClienteService _clienteService;

  /// Data de criação definida no init (somente leitura).
  final DateTime dataCriacao;

  RomaneioCriarViewModel(
    this._pedidoService,
    this._romaneioService,
    this._empresaService,
    this._clienteService,
  )
      : dataCriacao = DateTime.now() {
    _gerarNumeroInicial();
    _ouvirCamposMotorista();
    carregarPedidosDisponiveis();
  }

  /// Atualiza a UI quando nome ou placa do motorista mudam (habilita/atualiza botão e resumo).
  void _ouvirCamposMotorista() {
    void onChanged() {
      if (!isDisposed) notifyListeners();
    }
    nomeMotoristaController.addListener(onChanged);
    placaVeiculoController.addListener(onChanged);
  }

  void _gerarNumeroInicial() {
    final d = dataCriacao;
    final y = d.year.toString();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    numeroController.text = 'ROM-$y$m$day-0001';
  }

  final TextEditingController numeroController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();
  final TextEditingController nomeMotoristaController = TextEditingController();
  final TextEditingController placaVeiculoController = TextEditingController();

  TipoMotorista _tipoMotorista = TipoMotorista.agregado;
  TipoMotorista get tipoMotorista => _tipoMotorista;

  List<PedidoListagemModel> _pedidosDisponiveis = [];
  final Set<int> _idsSelecionados = {};
  final Map<int, String> _nomesClientes = {};
  /// Volume por id de pedido (soma das quantidades dos itens), carregado ao selecionar o pedido.
  final Map<int, int> _volumePorPedido = {};
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  bool get isLoadingPedidos => _isLoadingPedidos;
  String? get errorMessage => _errorMessage;

  List<PedidoListagemModel> get pedidosDisponiveis =>
      List.unmodifiable(_pedidosDisponiveis);

  /// Pedidos filtrados pela busca (id, cliente, status, valor).
  List<PedidoListagemModel> get pedidosFiltrados {
    if (_searchQuery.trim().isEmpty) return _pedidosDisponiveis;
    final q = _searchQuery.trim().toLowerCase();
    return _pedidosDisponiveis.where((p) {
      return p.idPedido.toString().contains(q) ||
          p.idCliente.toString().contains(q) ||
          p.status.toLowerCase().contains(q) ||
          p.total.toString().replaceAll('.', ',').contains(q);
    }).toList();
  }

  String get searchQuery => _searchQuery;
  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    if (!isDisposed) notifyListeners();
  }

  List<PedidoListagemModel> get pedidosSelecionados =>
      _pedidosDisponiveis.where((p) => _idsSelecionados.contains(p.idPedido)).toList();

  /// Nome do cliente por [idCliente]. Retorna '—' se não encontrado.
  String nomeCliente(int idCliente) => _nomesClientes[idCliente] ?? '—';

  /// IDs dos pedidos selecionados (para uso em UI/validação).
  List<int> get pedidosSelecionadosIds => _idsSelecionados.toList();

  /// Indica se o motorista é próprio (exige nome e placa).
  bool get isMotoristaProprio => _tipoMotorista == TipoMotorista.proprio;

  void _calcularTotais() {
    if (!isDisposed) notifyListeners();
  }

  double get valorTotal {
    double total = 0;
    for (final p in pedidosSelecionados) {
      total += p.total;
    }
    return total;
  }

  /// Volume total = soma das quantidades dos itens dos pedidos selecionados.
  /// Buscado ao selecionar cada pedido (listar itens e somar quantidade); não é digitável.
  int get volumeTotal {
    int total = 0;
    for (final id in _idsSelecionados) {
      total += _volumePorPedido[id] ?? 0;
    }
    return total;
  }

  int get quantidadePedidos => pedidosSelecionados.length;

  void setTipoMotorista(TipoMotorista valor) {
    if (_tipoMotorista == valor) return;
    _tipoMotorista = valor;
    if (valor == TipoMotorista.agregado) {
      nomeMotoristaController.clear();
      placaVeiculoController.clear();
    }
    if (!isDisposed) notifyListeners();
  }

  bool estaSelecionado(PedidoListagemModel pedido) =>
      _idsSelecionados.contains(pedido.idPedido);

  void togglePedido(PedidoListagemModel pedido) {
    final id = pedido.idPedido;
    if (_idsSelecionados.contains(id)) {
      _idsSelecionados.remove(id);
      _volumePorPedido.remove(id);
    } else {
      _idsSelecionados.add(id);
      _carregarVolumeDoPedido(id);
    }
    _calcularTotais();
  }

  /// Busca os itens do pedido e calcula o volume (soma das quantidades). Atualiza a UI ao terminar.
  Future<void> _carregarVolumeDoPedido(int idPedido) async {
    try {
      final itens = await _pedidoService.listarItensPedido(idPedido);
      final volume = itens.fold<int>(0, (s, item) => s + item.quantidade);
      if (!isDisposed) {
        _volumePorPedido[idPedido] = volume;
        notifyListeners();
      }
    } catch (_) {
      if (!isDisposed) {
        _volumePorPedido[idPedido] = 0;
        notifyListeners();
      }
    }
  }

  /// Calcula totais a partir dos pedidos selecionados (valorTotal e quantidadePedidos).
  void calcularTotais() {
    _calcularTotais();
  }

  /// Valida formulário completo. Retorna null se válido, ou mensagem de erro.
  String? validarFormulario() {
    if (numeroController.text.trim().isEmpty) {
      return 'Número do romaneio é obrigatório.';
    }
    if (quantidadePedidos < 1) {
      return 'Selecione pelo menos um pedido.';
    }
    return validarDadosMotorista();
  }

  /// Valida dados do motorista conforme tipo.
  /// Tipo 1 (próprio): exige apenas nome. Placa é opcional; se preenchida, valida formato.
  /// Tipo 2 (agregado): não exige. Retorna mensagem de erro ou null se válido.
  String? validarDadosMotorista() {
    if (_tipoMotorista == TipoMotorista.agregado) return null;
    final nome = nomeMotoristaController.text.trim();
    if (nome.isEmpty) return 'Informe o nome do motorista.';
    final placa = placaVeiculoController.text.trim();
    if (placa.isNotEmpty) return AppValidators.placaVeiculo(placa);
    return null;
  }

  /// Habilita o botão Criar: número preenchido, pelo menos 1 pedido e, se tipo próprio, nome preenchido (placa opcional).
  bool get podeCriar {
    if (numeroController.text.trim().isEmpty) return false;
    if (quantidadePedidos < 1) return false;
    if (_tipoMotorista == TipoMotorista.proprio) {
      final nome = nomeMotoristaController.text.trim();
      if (nome.isEmpty) return false;
      final placa = placaVeiculoController.text.trim();
      if (placa.isNotEmpty && AppValidators.placaVeiculo(placa) != null) return false;
    }
    return true;
  }

  /// Lista de itens que faltam para poder criar o romaneio.
  List<String> get camposFaltantes {
    final faltantes = <String>[];
    if (numeroController.text.trim().isEmpty) {
      faltantes.add('Número do romaneio');
    }
    if (quantidadePedidos < 1) {
      faltantes.add('Selecione pelo menos um pedido');
    }
    if (_tipoMotorista == TipoMotorista.proprio) {
      final nome = nomeMotoristaController.text.trim();
      if (nome.isEmpty) faltantes.add('Nome do motorista');
      final placa = placaVeiculoController.text.trim();
      if (placa.isNotEmpty && AppValidators.placaVeiculo(placa) != null) {
        faltantes.add('Placa do veículo (inválida)');
      }
    }
    return faltantes;
  }

  Future<void> carregarPedidosDisponiveis() async {
    _isLoadingPedidos = true;
    _errorMessage = null;
    if (!isDisposed) notifyListeners();

    try {
      _pedidosDisponiveis = await _pedidoService.listarPedidos(
        status: kStatusProntoEntrega,
      );
      final idsCliente = _pedidosDisponiveis
          .map((p) => p.idCliente)
          .where((id) => id > 0)
          .toSet()
          .toList();
      if (idsCliente.isNotEmpty) {
        final clientes = await _clienteService.listarClientes(
          status: 'ativa',
          q: null,
          includeDeleted: false,
        );
        for (final c in clientes) {
          if (c.id != null) _nomesClientes[c.id!] = c.nome;
        }
      }
    } catch (_) {
      _errorMessage = 'Erro ao carregar pedidos. Tente novamente.';
    } finally {
      _isLoadingPedidos = false;
      if (!isDisposed) notifyListeners();
    }
  }

  /// Valida e cria o romaneio. Retorna true se sucesso.
  Future<bool> criarRomaneio() async {
    final numero = numeroController.text.trim();
    if (numero.isEmpty) {
      _errorMessage = 'Informe o número do romaneio.';
      if (!isDisposed) notifyListeners();
      return false;
    }

    final selecionados = pedidosSelecionados;
    if (selecionados.isEmpty) {
      _errorMessage = 'Selecione pelo menos um pedido.';
      if (!isDisposed) notifyListeners();
      return false;
    }

    final erroMotorista = validarDadosMotorista();
    if (erroMotorista != null) {
      _errorMessage = erroMotorista;
      if (!isDisposed) notifyListeners();
      return false;
    }

    _errorMessage = null;
    _isLoading = true;
    if (!isDisposed) notifyListeners();

    try {
      final motoristaEntregador = _tipoMotorista == TipoMotorista.proprio
          ? nomeMotoristaController.text.trim()
          : 'Agregado';
      final pedidosIds = selecionados.map((p) => p.idPedido).toList();

      final placa = placaVeiculoController.text.trim();
      await _romaneioService.criarRomaneio(
        idEmpresa: _empresaService.idEmpresa,
        motoristaEntregador: motoristaEntregador,
        pedidos: pedidosIds,
        totalFaturado: valorTotal,
        placaVeiculo: placa.isEmpty ? null : placa,
      );
      for (final idPedido in pedidosIds) {
        await _pedidoService.alterarStatusPedido(
          idPedido,
          _empresaService.idEmpresa,
          kStatusPedidoOrganizado,
        );
      }
      _isLoading = false;
      if (!isDisposed) notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _mensagemErroAmigavel(e);
      if (!isDisposed) notifyListeners();
      return false;
    }
  }

  String _mensagemErroAmigavel(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('timeout') || msg.contains('connection')) {
      return 'Tempo esgotado. Verifique sua conexão.';
    }
    if (msg.contains('500') || msg.contains('servidor')) {
      return 'Erro no servidor. Tente novamente mais tarde.';
    }
    return 'Erro ao criar romaneio. Tente novamente.';
  }

  @override
  void dispose() {
    numeroController.dispose();
    observacaoController.dispose();
    nomeMotoristaController.dispose();
    placaVeiculoController.dispose();
    super.dispose();
  }
}
