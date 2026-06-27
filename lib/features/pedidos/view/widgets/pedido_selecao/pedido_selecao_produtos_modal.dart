import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/pedidos/contracts/pedido_selecao_produtos_contract.dart';
import 'package:erp_alianca_dev/features/pedidos/model/item_pedido_linha.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_selecao/pedido_selecao_chip_escolhido.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_selecao/pedido_selecao_produto_linha.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';
import 'package:erp_alianca_dev/shared/widgets/app_primary_button.dart';

/// Mini tela (modal) para escolher vários produtos de uma vez.
/// Ao confirmar, os itens são adicionados ao pedido e o modal fecha.
class PedidoSelecaoProdutosModal extends StatefulWidget {
  const PedidoSelecaoProdutosModal({super.key});

  @override
  State<PedidoSelecaoProdutosModal> createState() =>
      _PedidoSelecaoProdutosModalState();
}

class _PedidoSelecaoProdutosModalState extends State<PedidoSelecaoProdutosModal> {
  final List<ItemPedidoLinha> _selecionados = [];
  final FocusNode _searchFocusNode = FocusNode();
  TextEditingController? _searchController;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<PedidoSelecaoProdutosVm>();
      _searchController = vm.produtoQueryController;
      vm.carregarTodosProdutos();
      _searchController!.addListener(_onSearchChanged);
    });
  }

  @override
  void dispose() {
    _searchController?.removeListener(_onSearchChanged);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  void _limparPesquisa() {
    final vm = context.read<PedidoSelecaoProdutosVm>();
    vm.produtoQueryController.clear();
    setState(() {});
  }

  void _adicionarNaSelecao(ProdutoModel p) {
    final id = p.idProduto;
    final idx = id == null
        ? -1
        : _selecionados.indexWhere((e) => e.produto.idProduto == id);
    if (idx >= 0) {
      final item = _selecionados[idx];
      _selecionados[idx] = ItemPedidoLinha(
        produto: item.produto,
        quantidade: item.quantidade + 1,
      );
    } else {
      _selecionados.add(ItemPedidoLinha(produto: p, quantidade: 1));
    }
    setState(() {});
  }

  void _removerDaSelecao(int index) {
    if (index >= 0 && index < _selecionados.length) {
      _selecionados.removeAt(index);
      setState(() {});
    }
  }

  bool _estaNosEscolhidos(ProdutoModel p) {
    final id = p.idProduto;
    if (id == null) return false;
    return _selecionados.any((e) => e.produto.idProduto == id);
  }

  Future<void> _confirmar() async {
    if (_selecionados.isEmpty || _isConfirming) return;
    _isConfirming = true;
    setState(() {});
    final vm = context.read<PedidoSelecaoProdutosVm>();
    await vm.adicionarItens(List.from(_selecionados));
    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildListaProdutos(PedidoSelecaoProdutosVm vm) {
    if (vm.stateBuscaProduto == ViewState.loading && vm.todosProdutos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.todosProdutos.isEmpty) {
      return Center(
        child: Text(
          'Nenhum produto cadastrado.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    final query = vm.produtoQueryController.text.trim().toLowerCase();
    final filtrados = query.isEmpty
        ? vm.todosProdutos
        : vm.todosProdutos
            .where((p) => p.nome.toLowerCase().contains(query))
            .toList();
    if (filtrados.isEmpty) {
      return Center(
        child: Text(
          'Nenhum produto com esse nome.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      itemCount: (filtrados.length + 1) ~/ 2,
      itemBuilder: (context, rowIndex) {
        final leftIndex = rowIndex * 2;
        final rightIndex = leftIndex + 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildProdutoCard(filtrados[leftIndex]),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: rightIndex < filtrados.length
                    ? _buildProdutoCard(filtrados[rightIndex])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProdutoCard(ProdutoModel p) {
    return PedidoSelecaoProdutoLinha(
      nome: p.nome,
      precoTexto: 'R\$ ${formatarPreco(p.preco)}',
      onTap: () => _adicionarNaSelecao(p),
      jaAdicionado: _estaNosEscolhidos(p),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidoSelecaoProdutosVm>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Adicionar produtos',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: vm.produtoQueryController,
                      focusNode: _searchFocusNode,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Digite para buscar pelo nome',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: vm.produtoQueryController.text.trim().isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _limparPesquisa,
                                tooltip: 'Limpar pesquisa',
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: AppColors.listagemSearchBarBackground,
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Produtos',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _buildListaProdutos(vm),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Text(
                    'Escolhidos',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_selecionados.isNotEmpty)
                    Text(
                      ' (${_selecionados.length})',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_selecionados.isEmpty)
                Text(
                  'Toque nos produtos acima para adicionar.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: List.generate(_selecionados.length, (index) {
                    final item = _selecionados[index];
                    return PedidoSelecaoChipEscolhido(
                      label: '${item.produto.nome} × ${item.quantidade}',
                      onRemover: () => _removerDaSelecao(index),
                    );
                  }),
                ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: 'Confirmar e adicionar ao pedido',
                isLoading: _isConfirming,
                onPressed: (_selecionados.isEmpty || _isConfirming)
                    ? null
                    : _confirmar,
              ),
            ],
          ),
        );
      },
    );
  }
}
