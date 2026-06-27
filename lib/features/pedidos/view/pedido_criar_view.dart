import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_cliente_selector.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_forma_pagamento_field.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_tabela_itens.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_section_header.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_criar_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_primary_button.dart';
import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';
import 'package:erp_alianca_dev/features/pedidos/contracts/pedido_selecao_produtos_contract.dart';
import 'package:erp_alianca_dev/features/pedidos/view/pedido_selecao_cliente_modal.dart';
import 'package:erp_alianca_dev/features/pedidos/view/pedido_selecao_produtos_modal.dart';

class PedidoCriarView extends StatelessWidget {
  const PedidoCriarView({super.key});

  static const double _breakpointDoisPaineis = 900;

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidoCriarViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: 'Criar Pedido',
                icon: Icons.receipt_long_outlined,
                onBack: () => context.go(AppRoutes.pedidos),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final doisPaineis = constraints.maxWidth >= _breakpointDoisPaineis;
                    if (doisPaineis) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(
                              child: _PainelDadosCliente(vm: vm),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            flex: 6,
                            child: _PainelItensPedido(vm: vm, expandirCorpo: true),
                          ),
                        ],
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PainelDadosCliente(vm: vm),
                          const SizedBox(height: AppSpacing.lg),
                          _PainelItensPedido(vm: vm),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
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
          const PedidoCriarSectionHeader(
            title: 'Dados do Cliente',
            icon: Icons.person_outline,
          ),
          PedidoCriarClienteSelector(
            textoExibido: vm.clienteSelecionado?.nome,
            onEscolherCliente: () => _abrirModalSelecaoCliente(context, vm),
          ),
          const SizedBox(height: AppSpacing.fieldSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Nome',
                  controller: vm.clienteNomeDisplayController,
                  enabled: false,
                ),
              ),
              const SizedBox(width: AppSpacing.fieldSpacing),
              Expanded(
                child: AppTextField(
                  label: 'Telefone',
                  controller: vm.clienteTelefoneDisplayController,
                  enabled: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.fieldSpacing),
          AppTextField(
            label: 'Endereço',
            controller: vm.clienteEnderecoDisplayController,
            enabled: false,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.sectionSpacing),
          const PedidoCriarSectionHeader(
            title: 'Forma de Pagamento',
            icon: Icons.credit_card_outlined,
          ),
          PedidoCriarFormaPagamentoField(
            value: vm.formaPagamentoSelecionada,
            onChanged: (value) => vm.formaPagamentoSelecionada = value,
          ),
          const SizedBox(height: AppSpacing.sectionSpacing),
          const PedidoCriarSectionHeader(
            title: 'Total do Pedido',
            icon: Icons.payments_outlined,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.listagemItemBackground.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.cardBorder.withValues(alpha: 0.65),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valor Total',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${formatarPreco(vm.totalPedido)}',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _BadgeContador(
                  label: vm.itens.length == 1
                      ? '1 item'
                      : '${vm.itens.length} itens',
                ),
              ],
            ),
          ),
          if (vm.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(vm.errorMessage!, style: AppTextStyles.error),
          ],
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            label: 'Criar Pedido',
            isLoading: vm.isLoading,
            onPressed: vm.podeCriar && !vm.isLoading
                ? () => _aoCriarPedido(context, vm)
                : null,
          ),
        ],
      ),
    );
  }
}

class _PainelItensPedido extends StatelessWidget {
  const _PainelItensPedido({
    required this.vm,
    this.expandirCorpo = false,
  });

  final PedidoCriarViewModel vm;
  final bool expandirCorpo;

  @override
  Widget build(BuildContext context) {
    return _PainelBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: expandirCorpo ? MainAxisSize.max : MainAxisSize.min,
        children: [
          PedidoCriarSectionHeader(
            title: 'Itens do Pedido',
            icon: Icons.receipt_long_outlined,
            trailing: IgnorePointer(
              ignoring: vm.clienteSelecionado == null,
              child: Opacity(
                opacity: vm.clienteSelecionado != null ? 1 : 0.45,
                child: ElevatedButton.icon(
                  onPressed: vm.clienteSelecionado != null
                      ? () => _abrirModalSelecaoProdutos(context, vm)
                      : null,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar Produtos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.35),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.18),
                    disabledForegroundColor:
                        Colors.white.withValues(alpha: 0.55),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (expandirCorpo)
            Expanded(
              child: PedidoCriarTabelaItens(
                vm: vm,
                expandirCorpo: true,
              ),
            )
          else
            PedidoCriarTabelaItens(vm: vm),
        ],
      ),
    );
  }
}

class _BadgeContador extends StatelessWidget {
  const _BadgeContador({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PainelBase extends StatelessWidget {
  const _PainelBase({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: AppColors.cardBoxShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.formContainerPadding),
        child: child,
      ),
    );
  }
}

void _abrirModalSelecaoCliente(
  BuildContext context,
  PedidoCriarViewModel vm,
) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) {
      final size = MediaQuery.sizeOf(ctx);
      const modalFraction = 0.5;
      final modalWidth = size.width * modalFraction;
      final modalHeight = size.height * modalFraction;
      final horizontalInset = (size.width - modalWidth) / 2;
      final verticalInset = (size.height - modalHeight) / 2;
      return Dialog(
        backgroundColor: AppColors.contentBackground,
        insetPadding: EdgeInsets.fromLTRB(
          horizontalInset,
          verticalInset,
          horizontalInset,
          verticalInset,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: modalWidth,
            maxHeight: modalHeight,
          ),
          child: SizedBox(
            width: modalWidth,
            height: modalHeight,
            child: ListenableProvider<PedidoCriarViewModel>.value(
              value: vm,
              child: const PedidoSelecaoClienteModal(),
            ),
          ),
        ),
      );
    },
  );
}

void _abrirModalSelecaoProdutos(
  BuildContext context,
  PedidoCriarViewModel vm,
) {
  vm.limparBuscaProduto();
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) {
      final size = MediaQuery.sizeOf(ctx);
      const modalFraction = 0.5;
      final modalWidth = size.width * modalFraction;
      final modalHeight = size.height * modalFraction;
      final horizontalInset = (size.width - modalWidth) / 2;
      final verticalInset = (size.height - modalHeight) / 2;
      return Dialog(
        backgroundColor: AppColors.contentBackground,
        insetPadding: EdgeInsets.fromLTRB(
          horizontalInset,
          verticalInset,
          horizontalInset,
          verticalInset,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: modalWidth,
            maxHeight: modalHeight,
          ),
          child: SizedBox(
            width: modalWidth,
            height: modalHeight,
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
  BuildContext context,
  PedidoCriarViewModel vm,
) async {
  if (!vm.podeCriar || vm.isLoading) return;
  final sucesso = await vm.salvar();
  if (!context.mounted) return;
  if (sucesso) {
    showAppToast(context, message: 'Pedido criado com sucesso.');
    context.go(AppRoutes.pedidos);
  }
}
