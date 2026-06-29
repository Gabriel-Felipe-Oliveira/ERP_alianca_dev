import 'package:flutter/foundation.dart';
import 'package:erp_alianca_dev/core/utils/app_logger.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/romaneio/model/produto_agregado.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';

/// Carregamento de pedidos, itens e agregações do detalhe do romaneio.
mixin RomaneioDetalhePedidosMixin on ChangeNotifier {
  bool get isVmDisposed;
  PedidoService get pedidoService;
  ProdutoService get produtoService;
  ClienteService get clienteService;

  List<PedidoListagemModel> get pedidosDoRomaneioInterno;
  set pedidosDoRomaneioInterno(List<PedidoListagemModel> value);
  Map<int, List<PedidoItemModel>> get itensPorPedido;
  Map<int, String> get nomesProdutos;
  Map<int, String> get nomesClientesPorPedido;
  bool get loadingPedidosInterno;
  set loadingPedidosInterno(bool value);

  void limparDadosPedidos() {
    pedidosDoRomaneioInterno = [];
    itensPorPedido.clear();
    nomesClientesPorPedido.clear();
    nomesProdutos.clear();
  }

  int volumeDoPedido(int idPedido) {
    final itens = itensPorPedido[idPedido];
    if (itens == null) return 0;
    return itens.fold<int>(0, (s, i) => s + i.quantidade);
  }

  List<PedidoItemModel> itensDoPedido(int idPedido) =>
      List.unmodifiable(itensPorPedido[idPedido] ?? []);

  String nomeProduto(int idProduto) =>
      nomesProdutos[idProduto] ?? 'Produto #$idProduto';

  String nomeClienteDoPedido(int idPedido) {
    return nomesClientesPorPedido[idPedido]?.trim().isNotEmpty == true
        ? nomesClientesPorPedido[idPedido]!
        : '—';
  }

  double get totalFaturado {
    double total = 0;
    for (final itens in itensPorPedido.values) {
      for (final i in itens) {
        total += i.subtotal;
      }
    }
    return total;
  }

  int get totalVolumes => pedidosDoRomaneioInterno.fold<int>(
        0,
        (sum, p) => sum + volumeDoPedido(p.idPedido),
      );

  List<ProdutoAgregado> get produtosAgregados {
    final map = <int, ({int qtd, double subtotal})>{};
    for (final itens in itensPorPedido.values) {
      for (final i in itens) {
        final cur = map[i.idProduto];
        if (cur == null) {
          map[i.idProduto] = (qtd: i.quantidade, subtotal: i.subtotal);
        } else {
          map[i.idProduto] = (
            qtd: cur.qtd + i.quantidade,
            subtotal: cur.subtotal + i.subtotal,
          );
        }
      }
    }
    return map.entries
        .map(
          (e) => ProdutoAgregado(
            idProduto: e.key,
            nome: nomeProduto(e.key),
            quantidadeTotal: e.value.qtd,
            subtotalTotal: e.value.subtotal,
          ),
        )
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  double get percentualOcupacao {
    if (capacidadeCaminhaoVolumes <= 0) return 0.0;
    return (totalVolumes / capacidadeCaminhaoVolumes) * 100;
  }

  double get valorTotalPedidos => pedidosDoRomaneioInterno.fold<double>(
        0,
        (s, p) => s + p.total,
      );

  Future<void> carregarPedidosEItens(List<int> ids) async {
    loadingPedidosInterno = true;
    nomesClientesPorPedido.clear();
    if (!isVmDisposed) notifyListeners();
    try {
      pedidosDoRomaneioInterno =
          await pedidoService.listarPedidosPorIds(ids);
      for (final p in pedidosDoRomaneioInterno) {
        final itens = await pedidoService.listarItensPedido(p.idPedido);
        itensPorPedido[p.idPedido] = itens;
        if (p.idCliente > 0) {
          try {
            final cliente =
                await clienteService.buscarClientePorId(p.idCliente);
            final nome = cliente.nome.trim();
            if (nome.isNotEmpty) {
              nomesClientesPorPedido[p.idPedido] = nome;
            }
          } catch (e) {
            AppLogger.debug(
                'Falha ao resolver nome do cliente ${p.idCliente}: $e',
                tag: 'RomaneioDetalhePedidos');
          }
        }
      }
      await carregarNomesProdutos();
    } catch (e) {
      AppLogger.debug('Falha ao carregar pedidos do romaneio: $e',
          tag: 'RomaneioDetalhePedidos');
      pedidosDoRomaneioInterno = [];
      itensPorPedido.clear();
      nomesClientesPorPedido.clear();
    } finally {
      loadingPedidosInterno = false;
      if (!isVmDisposed) notifyListeners();
    }
  }

  Future<void> carregarNomesProdutos() async {
    final ids = <int>{};
    for (final list in itensPorPedido.values) {
      for (final item in list) {
        ids.add(item.idProduto);
      }
    }
    for (final id in ids) {
      if (isVmDisposed) return;
      try {
        final produto = await produtoService.buscarPorId(id);
        if (produto != null && produto.nome.isNotEmpty) {
          nomesProdutos[id] = produto.nome;
        }
      } catch (e) {
        AppLogger.debug('Falha ao resolver nome do produto $id: $e',
            tag: 'RomaneioDetalhePedidos');
      }
    }
  }
}
