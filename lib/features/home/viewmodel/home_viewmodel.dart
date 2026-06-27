import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/shared/services/dashboard_service.dart';

class HomeViewModel extends BaseViewModel {
  bool _isLoading = false;
  String? _errorMessage;

  int _totalClientes = 0;
  int _totalProdutos = 0;
  int _totalPedidos = 0;

  String _clienteComMaisPedidos = '—';
  String _produtoMaisVendido = '—';
  String _maiorPedido = '—';

  final DashboardService _dashboardService;

  HomeViewModel(this._dashboardService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalClientes => _totalClientes;
  int get totalProdutos => _totalProdutos;
  int get totalPedidos => _totalPedidos;
  String get clienteComMaisPedidos => _clienteComMaisPedidos;
  String get produtoMaisVendido => _produtoMaisVendido;
  String get maiorPedido => _maiorPedido;

  @override
  void dispose() {
    super.dispose();
  }

  /// Carrega os 3 totais do dashboard (clientes, produtos, pedidos concluídos) ao entrar na home.
  Future<void> carregarDados() async {
    _isLoading = true;
    _errorMessage = null;
    if (!isDisposed) notifyListeners();

    try {
      final resumo = await _dashboardService.buscarResumo();
      if (isDisposed) return;
      _totalClientes = resumo.totalClientes;
      _totalProdutos = resumo.totalProdutos;
      _totalPedidos = resumo.totalPedidosConcluidos;
      _clienteComMaisPedidos = '—';
      _produtoMaisVendido = '—';
      _maiorPedido = '—';
    } on AppException catch (e) {
      if (!isDisposed) _errorMessage = e.message;
    } catch (e) {
      if (!isDisposed) {
        _errorMessage = BaseViewModel.userMessage(
          e,
          'Erro ao carregar dados.',
        );
      }
    } finally {
      _isLoading = false;
      if (!isDisposed) notifyListeners();
    }
  }
}
