import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/models/navigation_entry.dart';

/// Limite máximo de entradas no histórico para evitar consumo de memória.
const int _maxHistorico = 50;

/// Controlador global de navegação do app.
///
/// Responsável por:
/// - Manter histórico de rotas com dados extras (sem stack do Flutter)
/// - Evitar duplicação consecutiva de rotas
/// - Limitar tamanho do histórico
/// - Bloquear/liberar navegação (ex.: durante salvamento ou pesquisa)
/// - Indicar estado de loading
///
/// O app navega sempre com [context.go()] (substitui a tela, sem stack).
/// O histórico é mantido aqui manualmente, leve e controlado.
class NavigationController extends ChangeNotifier {
  bool _disposed = false;

  // ─── Histórico de rotas ───────────────────────────────────────────

  /// Lista de entradas visitadas. Sempre começa com Home.
  final List<NavigationEntry> _historico = [
    const NavigationEntry(rota: '/'),
  ];

  /// Entrada atual (última do histórico).
  NavigationEntry get entradaAtual => _historico.last;

  /// Rota atual (path string, atalho).
  String get rotaAtual => _historico.last.rota;

  /// Quantidade de entradas no histórico.
  int get tamanhoHistorico => _historico.length;

  /// Histórico completo (somente leitura, útil para debug).
  List<NavigationEntry> get historico => List.unmodifiable(_historico);

  /// Registra uma nova rota no histórico.
  ///
  /// Proteções:
  /// - Ignora se a rota for igual à atual (evita duplicação consecutiva).
  /// - Remove entradas antigas se ultrapassar [_maxHistorico].
  /// - Aceita dados extras (ex.: ID de cliente).
  ///
  /// Exemplo:
  /// ```dart
  /// navController.registrarRota('/clientes/detalhe', dados: {'idCliente': 42});
  /// ```
  void registrarRota(String rota, {Map<String, Object?> dados = const {}}) {
    final novaEntrada = NavigationEntry(rota: rota, dados: dados);

    // Proteção: não duplicar mesma rota consecutivamente
    if (_historico.isNotEmpty && _historico.last.mesmaRota(novaEntrada)) return;

    _historico.add(novaEntrada);

    // Proteção: limitar tamanho do histórico (remove as mais antigas, mantém Home)
    while (_historico.length > _maxHistorico) {
      _historico.removeAt(1); // nunca remove Home (index 0)
    }

    notifyListeners();
  }

  /// Limpa todo o histórico e volta ao estado inicial (Home).
  /// Útil após logout, troca de contexto, ou fluxo completo.
  void limparHistorico() {
    _historico.clear();
    _historico.add(const NavigationEntry(rota: '/'));
    notifyListeners();
  }

  /// Limpa o histórico e define uma nova rota como ponto de partida.
  /// Útil após completar um fluxo (ex.: criou cliente → vai pra listagem).
  ///
  /// Exemplo: após criar cliente, redirecionar para listagem limpa:
  /// ```dart
  /// navController.limparENavegar('/clientes');
  /// context.go('/clientes');
  /// ```
  void limparENavegar(String rota, {Map<String, Object?> dados = const {}}) {
    _historico.clear();
    _historico.add(const NavigationEntry(rota: '/'));
    _historico.add(NavigationEntry(rota: rota, dados: dados));
    notifyListeners();
  }

  /// Substitui a entrada atual no histórico (sem adicionar nova).
  /// Útil para redirecionar sem acumular histórico.
  ///
  /// Exemplo: de "/clientes/criar" para "/clientes/criar" com novos dados,
  /// ou de "/clientes/criar" para "/clientes/editar" sem voltar pra criar.
  void substituirAtual(String rota, {Map<String, Object?> dados = const {}}) {
    if (_historico.isNotEmpty) {
      _historico.removeLast();
    }
    _historico.add(NavigationEntry(rota: rota, dados: dados));
    notifyListeners();
  }

  /// Recupera os dados da entrada atual.
  /// Atalho para [entradaAtual.obterDado<T>(chave)].
  T? obterDadoAtual<T>(String chave) => entradaAtual.obterDado<T>(chave);

  // ─── Controle de navegação (bloquear/liberar) ─────────────────────

  /// Quando false, navegação e ações da barra ficam desabilitadas.
  bool _canNavigate = true;
  bool get canNavigate => _canNavigate;

  /// Indica que uma operação assíncrona está em andamento.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Bloqueia a navegação (e ações da barra).
  void bloquear() {
    if (_canNavigate == false) return;
    _canNavigate = false;
    notifyListeners();
  }

  /// Libera a navegação.
  void liberar() {
    if (_canNavigate == true) return;
    _canNavigate = true;
    notifyListeners();
  }

  /// Marca início de loading (bloqueia navegação enquanto durar).
  void iniciarLoading() {
    _isLoading = true;
    _canNavigate = false;
    notifyListeners();
  }

  /// Marca fim do loading e libera navegação.
  void finalizarLoading() {
    _isLoading = false;
    _canNavigate = true;
    notifyListeners();
  }

  /// Botões habilitados quando pode navegar e não está em loading.
  bool get buttonsEnabled => _canNavigate && !_isLoading;

  // ─── Lifecycle ────────────────────────────────────────────────────

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
