import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/model/forma_pagamento_pedido.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_detalhe_actions.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_detalhes_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';
import 'package:erp_alianca_dev/shared/widgets/app_dropdown_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_form_container.dart';
import 'package:erp_alianca_dev/shared/widgets/app_primary_button.dart';
import 'package:erp_alianca_dev/shared/widgets/app_section_title.dart';
import 'package:erp_alianca_dev/shared/widgets/app_total_pedido_field.dart';
import 'package:erp_alianca_dev/shared/widgets/pedido_item_row.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';

const double kPedidoDetalheBreakpointDoisPaineis = 900;

/// Corpo da tela em modo de edição do pedido.
class PedidoDetalheEditBody extends StatelessWidget {
  const PedidoDetalheEditBody({
    super.key,
    required this.vm,
    required this.onBack,
  });

  final PedidoDetalhesViewModel vm;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SectionHeader(
          title: 'Editar pedido',
          description: 'Altere as quantidades, remova itens ou adicione novos.',
          onBack: onBack,
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final doisPaineis =
                constraints.maxWidth >= kPedidoDetalheBreakpointDoisPaineis;
            if (doisPaineis) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _PainelAdicionar(vm: vm)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _PainelProdutosEscolhidos(vm: vm)),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _PainelAdicionar(vm: vm),
                const SizedBox(height: AppSpacing.lg),
                _PainelProdutosEscolhidos(vm: vm),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PainelAdicionar extends StatelessWidget {
  const _PainelAdicionar({required this.vm});

  final PedidoDetalhesViewModel vm;

  @override
  Widget build(BuildContext context) {
    return AppFormContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSectionTitle(title: 'Adicionar pedido'),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => pedidoAbrirModalSelecaoProdutos(context, vm),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: AppColors.success.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                overlayColor: Colors.white.withValues(alpha: 0.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_shopping_cart, size: 20),
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
          const SizedBox(height: AppSpacing.sectionSpacing),
          const AppSectionTitle(title: 'Pagamento'),
          AppDropdownField<String>(
            label: 'Forma de pagamento',
            value: vm.formaPagamentoEdicao,
            items: FormaPagamentoPedido.valoresInternos
                .map(
                  (v) => DropdownMenuItem<String>(
                    value: v,
                    child: Text(
                      v.isEmpty
                          ? FormaPagamentoPedido.labelOpcaoVazia
                          : v,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => vm.formaPagamentoEdicao = v ?? '',
          ),
          const SizedBox(height: AppSpacing.sectionSpacing),
          const AppSectionTitle(title: 'Total do Pedido'),
          AppTotalPedidoField(total: vm.totalPedido),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: vm.isSavingEdicao ? 'Salvando...' : 'Confirmar',
            onPressed: vm.isSavingEdicao
                ? null
                : () => vm.confirmarEdicaoPedido(),
          ),
        ],
      ),
    );
  }
}

class _PainelProdutosEscolhidos extends StatelessWidget {
  const _PainelProdutosEscolhidos({required this.vm});

  final PedidoDetalhesViewModel vm;

  @override
  Widget build(BuildContext context) {
    return AppFormContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSectionTitle(title: 'Produtos escolhidos'),
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
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = vm.itens[index];
                return PedidoItemRow(
                  nome: vm.nomeProduto(item.idProduto),
                  valorTexto: 'R\$ ${formatarPreco(item.precoUnitario)}',
                  quantidadeTexto: item.quantidade.toString(),
                  totalTexto:
                      'R\$ ${formatarPreco(item.precoUnitario * item.quantidade)}',
                  index: index,
                  onQuantidadeChanged: vm.atualizarQuantidadeItemPorIndex,
                  valorEditavel: true,
                  valorEditavelInicial: item.precoUnitario,
                  onValorChanged: vm.atualizarValorItemPorIndex,
                  onRemover: () => vm.removerItem(item.idItem),
                );
              },
            ),
        ],
      ),
    );
  }
}
