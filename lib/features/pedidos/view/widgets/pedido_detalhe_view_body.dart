import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_detalhe_itens_table.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_detalhes_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_detail_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_form_container.dart';
import 'package:erp_alianca_dev/shared/widgets/app_shimmer.dart';
import 'package:erp_alianca_dev/shared/widgets/app_total_pedido_field.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';

/// Conteúdo read-only do detalhe do pedido (loading, erro ou dados).
class PedidoDetalheViewBody extends StatelessWidget {
  const PedidoDetalheViewBody({
    super.key,
    required this.vm,
    required this.onBack,
  });

  final PedidoDetalhesViewModel vm;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    if (vm.state == ViewState.loading && vm.itens.isEmpty) {
      return AppFormContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppShimmer(width: 160, height: 22),
            const SizedBox(height: AppSpacing.md),
            ...List.generate(
              5,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppShimmer(width: double.infinity, height: 48),
              ),
            ),
          ],
        ),
      );
    }

    if (vm.state == ViewState.error && vm.itens.isEmpty) {
      return AppFormContainer(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Text(
                vm.errorMessage,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => vm.loadItens(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SectionHeader(
          title: 'Detalhes do pedido',
          description:
              'Visualize os dados do pedido. Use o painel para editar, gerar recibo ou imprimir.',
          onBack: onBack,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppFormContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _sectionTitleCompact('Dados do Cliente'),
              const SizedBox(height: 4),
              AppDetailField(label: 'Cliente', value: vm.nomeCliente),
              if (vm.enderecoFormatado.isNotEmpty &&
                  vm.enderecoFormatado != '—') ...[
                const SizedBox(height: AppSpacing.fieldSpacingCompact),
                AppDetailField(
                  label: 'Endereço',
                  value: vm.enderecoFormatado,
                ),
              ],
              const SizedBox(height: AppSpacing.sectionSpacingCompact),
              _sectionTitleCompact('Itens do Pedido'),
              if (vm.itens.isEmpty)
                Text(
                  'Nenhum item neste pedido.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              else
                PedidoDetalheItensTable(vm: vm),
              const SizedBox(height: AppSpacing.sectionSpacingCompact),
              AppDetailField(
                label: 'Pagamento',
                value: vm.pagamentoExibicao,
                filled: false,
              ),
              const SizedBox(height: AppSpacing.sectionSpacingCompact),
              _sectionTitleCompact('Total do Pedido'),
              const SizedBox(height: 4),
              AppTotalPedidoField(total: vm.totalPedido),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitleCompact(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        title,
        style: AppTextStyles.sectionTitle,
      ),
    );
  }
}
