import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_cliente_selector.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_forma_pagamento_field.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_modais.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_painel_base.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_section_header.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_criar_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';
import 'package:erp_alianca_dev/shared/widgets/app_primary_button.dart';
import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';

/// Painel com dados do cliente, forma de pagamento, total e ação de criar.
class PedidoCriarPainelCliente extends StatelessWidget {
  const PedidoCriarPainelCliente({super.key, required this.vm});

  final PedidoCriarViewModel vm;

  @override
  Widget build(BuildContext context) {
    return PedidoCriarPainelBase(
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
            onEscolherCliente: () =>
                PedidoCriarModais.abrirSelecaoCliente(context, vm),
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
          _ResumoTotal(vm: vm),
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
}

class _ResumoTotal extends StatelessWidget {
  const _ResumoTotal({required this.vm});

  final PedidoCriarViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
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
