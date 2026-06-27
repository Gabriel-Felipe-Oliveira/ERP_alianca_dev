import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/pedidos/model/forma_pagamento_pedido.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_criar_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_primary_button.dart';
import 'package:erp_alianca_dev/shared/widgets/app_section_title.dart';
import 'package:erp_alianca_dev/shared/widgets/app_dropdown_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';
import 'package:erp_alianca_dev/shared/widgets/compact_search_select.dart';
import 'package:erp_alianca_dev/features/pedidos/contracts/pedido_selecao_produtos_contract.dart';
import 'package:erp_alianca_dev/features/pedidos/view/pedido_selecao_produtos_modal.dart';
import 'package:erp_alianca_dev/shared/widgets/pedido_item_row.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';
import 'package:erp_alianca_dev/shared/widgets/app_total_pedido_field.dart';

class PedidoCriarView extends StatelessWidget {
  const PedidoCriarView({super.key});

  static const double _breakpointDoisPaineis = 900;

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidoCriarViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final doisPaineis = constraints.maxWidth >= _breakpointDoisPaineis;
              final content = doisPaineis
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _PainelDadosCliente(vm: vm)),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(child: _PainelItensPedido(vm: vm)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PainelDadosCliente(vm: vm),
                        const SizedBox(height: AppSpacing.lg),
                        _PainelItensPedido(vm: vm),
                      ],
                    );
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(
                      title: 'Criar Pedido',
                      description:
                          'Escolha o cliente, adicione os produtos e confirme.',
                      onBack: () => context.go(AppRoutes.pedidos),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    content,
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PainelDadosCliente extends StatelessWidget {
  const _PainelDadosCliente({required this.vm});

  final PedidoCriarViewModel vm;

  @override
  Widget build(BuildContext context) {
    return _PainelBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSectionTitle(title: 'Dados do Cliente'),
          CompactSearchSelect<ClienteModel>(
            controller: vm.clienteQueryController,
            hintText: 'Clique aqui para carregar a lista de clientes',
            onSearch: vm.buscarClientesPorNome,
            onChanged: (_) => vm.agendarBuscaCliente(),
            onFocus: vm.carregarListaClientes,
            isLoading: vm.stateBuscaCliente == ViewState.loading,
            items: vm.clientesBusca,
            errorMessage: vm.errorBuscaCliente,
            onItemSelected: vm.selecionarCliente,
            itemBuilder: (context, c) => Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    c.nome,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (c.telefone.isNotEmpty)
                  Text(
                    c.telefone,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.fieldSpacing),
          AppTextField(
            label: 'Nome',
            controller: vm.clienteNomeDisplayController,
            enabled: false,
          ),
          const SizedBox(height: AppSpacing.fieldSpacing),
          AppTextField(
            label: 'Telefone',
            controller: vm.clienteTelefoneDisplayController,
            enabled: false,
          ),
          const SizedBox(height: AppSpacing.fieldSpacing),
          AppTextField(
            label: 'Endereço',
            controller: vm.clienteEnderecoDisplayController,
            enabled: false,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.fieldSpacing),
          const AppSectionTitle(title: 'Forma de Pagamento'),
          AppDropdownField<String>(
            label: 'Forma de Pagamento',
            value: vm.formaPagamentoSelecionada,
            items: FormaPagamentoPedido.valoresInternos
                .map(
                  (formaPagamento) => DropdownMenuItem<String>(
                    value: formaPagamento,
                    child: Text(
                      formaPagamento.isEmpty
                          ? FormaPagamentoPedido.labelOpcaoVazia
                          : formaPagamento,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                vm.formaPagamentoSelecionada = value ?? '',
          ),
          const SizedBox(height: AppSpacing.fieldSpacing),
          const AppSectionTitle(title: 'Total do Pedido'),
          AppTotalPedidoField(total: vm.totalPedido),
          if (vm.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              vm.errorMessage!,
              style: AppTextStyles.error,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            label: 'Criar Pedido',
            isLoading: vm.isLoading,
            onPressed: (vm.podeCriar && !vm.isLoading)
                ? () => _aoCriarPedido(context, vm)
                : null,
            onDisabledTap: (vm.podeCriar || vm.isLoading)
                ? null
                : () => _mostrarCamposFaltantes(context, vm),
          ),
        ],
      ),
    );
  }
}

class _PainelItensPedido extends StatelessWidget {
  const _PainelItensPedido({required this.vm});

  final PedidoCriarViewModel vm;

  @override
  Widget build(BuildContext context) {
    return _PainelBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSectionTitle(title: 'Itens do Pedido'),
          IgnorePointer(
            ignoring: vm.clienteSelecionado == null,
            child: Opacity(
              opacity: vm.clienteSelecionado != null ? 1 : 0.5,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: vm.clienteSelecionado != null
                      ? () => _abrirModalSelecaoProdutos(context, vm)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.sidebarItemBackground,
                    disabledForegroundColor: AppColors.textSecondary,
                    elevation: 2,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    overlayColor: AppColors.textPrimary.withValues(alpha: 0.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_shopping_cart, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Adicionar produtos',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionSpacing),
          const AppSectionTitle(title: 'Lista de Produtos'),
          if (vm.itens.isEmpty)
            Text(
              'Nenhum produto na lista.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.itens.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = vm.itens[index];
                return PedidoItemRow(
                  nome: item.produto.nome,
                  valorTexto: 'R\$ ${formatarPreco(item.valorEfetivo)}',
                  quantidadeTexto: item.quantidade.toString(),
                  totalTexto: 'R\$ ${formatarPreco(item.totalLinha)}',
                  index: index,
                  onQuantidadeChanged: vm.atualizarQuantidadeItem,
                  valorEditavel: true,
                  valorEditavelInicial: item.valorEfetivo,
                  onValorChanged: vm.atualizarValorItem,
                  onRemover: () => vm.removerItem(index),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Container em estilo de card para cada painel (sem maxWidth, preenche o espaço).
class _PainelBase extends StatelessWidget {
  const _PainelBase({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: AppSpacing.formContainerShadowBlurRadius,
            offset: Offset(0, AppSpacing.formContainerShadowOffsetY),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.formContainerPadding),
        child: child,
      ),
    );
  }
}

void _abrirModalSelecaoProdutos(
    BuildContext context, PedidoCriarViewModel vm) {
  vm.limparBuscaProduto();
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) {
      final size = MediaQuery.sizeOf(ctx);
      // Modal usa no máximo 75% da altura e 90% da largura — 25% da tela de fundo fica visível.
      final maxHeight = size.height * 0.75;
      final horizontalInset = size.width * 0.05;
      final verticalInset = size.height * 0.125;
      return Dialog(
        backgroundColor: AppColors.contentBackground,
        insetPadding: EdgeInsets.symmetric(
          horizontal: horizontalInset,
          vertical: verticalInset,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size.width - (horizontalInset * 2),
            maxHeight: maxHeight,
          ),
          child: SizedBox(
            height: maxHeight,
            child: ListenableProvider<PedidoSelecaoProdutosVm>.value(
              value: vm,
              child: const PedidoSelecaoProdutosModal(),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _aoCriarPedido(
    BuildContext context, PedidoCriarViewModel vm) async {
  final sucesso = await vm.salvar();
  if (!context.mounted) return;
  if (sucesso) {
    showAppToast(context, message: 'Pedido criado com sucesso.');
    context.go(AppRoutes.pedidos);
  }
}

void _mostrarCamposFaltantes(
    BuildContext context, PedidoCriarViewModel vm) {
  final faltantes = vm.camposFaltantes;
  if (faltantes.isEmpty) return;
  showAppToast(
    context,
    message: 'Complete: ${faltantes.join(', ')}.',
    isError: true,
    duration: const Duration(seconds: 3),
  );
}
