import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_selecao/pedido_selecao_cliente_linha.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tooltip.dart';

/// Mini tela (modal) para escolher um cliente na criação de pedido.
/// Ao tocar em um cliente, ele é selecionado e o modal fecha.
class PedidoSelecaoClienteModal extends StatefulWidget {
  const PedidoSelecaoClienteModal({super.key});

  @override
  State<PedidoSelecaoClienteModal> createState() =>
      _PedidoSelecaoClienteModalState();
}

class _PedidoSelecaoClienteModalState extends State<PedidoSelecaoClienteModal> {
  final FocusNode _searchFocusNode = FocusNode();
  TextEditingController? _searchController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<PedidoCriarViewModel>();
      _searchController = vm.clienteQueryController;
      _searchController!.addListener(_onSearchChanged);
      vm.iniciarModalSelecaoCliente();
    });
  }

  @override
  void dispose() {
    _searchController?.removeListener(_onSearchChanged);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  void _selecionarCliente(PedidoCriarViewModel vm, ClienteModel cliente) {
    vm.selecionarCliente(cliente);
    Navigator.of(context).pop();
  }

  Widget _buildListaClientes(PedidoCriarViewModel vm) {
    if (vm.stateBuscaCliente == ViewState.loading && vm.clientesBusca.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.stateBuscaCliente == ViewState.error && vm.clientesBusca.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vm.errorBuscaCliente ?? 'Erro ao carregar clientes.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: vm.carregarListaClientes,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (vm.clientesBusca.isEmpty) {
      return Center(
        child: Text(
          vm.clienteQueryController.text.trim().isEmpty
              ? 'Nenhum cliente cadastrado.'
              : 'Nenhum cliente encontrado para esta busca.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final selecionadoId = vm.clienteSelecionado?.id;

    return ListView.separated(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      itemCount: vm.clientesBusca.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final cliente = vm.clientesBusca[index];
        final codigo = cliente.id != null
            ? '#${cliente.id!.toString().padLeft(5, '0')}'
            : '—';
        return PedidoSelecaoClienteLinha(
          nome: cliente.nome,
          telefone: cliente.telefone,
          codigo: codigo,
          selecionado: selecionadoId != null && cliente.id == selecionadoId,
          onTap: () => _selecionarCliente(vm, cliente),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidoCriarViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Escolher cliente',
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
              TextField(
                controller: vm.clienteQueryController,
                focusNode: _searchFocusNode,
                onChanged: (_) {
                  vm.agendarBuscaCliente();
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Buscar clientes por nome...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: vm.clienteQueryController.text.trim().isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            vm.clienteQueryController.clear();
                            vm.carregarListaClientes();
                            setState(() {});
                          },
                          tooltip: windowsSafeTooltip('Limpar pesquisa'),
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
              const SizedBox(height: AppSpacing.sm),
              Text(
                vm.stateBuscaCliente == ViewState.loading
                    ? 'Carregando clientes...'
                    : '${vm.clientesBusca.length} cliente(s)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(child: _buildListaClientes(vm)),
            ],
          ),
        );
      },
    );
  }
}
