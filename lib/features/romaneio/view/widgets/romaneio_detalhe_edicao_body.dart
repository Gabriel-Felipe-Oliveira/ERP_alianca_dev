import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_campo_logistica.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_detalhe_actions.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_detalhe_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';
import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';

/// Corpo da tela em modo de edição do romaneio.
class RomaneioDetalheEdicaoBody extends StatelessWidget {
  const RomaneioDetalheEdicaoBody({
    super.key,
    required this.vm,
  });

  final RomaneioDetalheViewModel vm;

  @override
  Widget build(BuildContext context) {
    final mc = vm.motoristaEditController;
    final pc = vm.placaEditController;
    if (mc == null || pc == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.sidebarBackground,
              borderRadius: BorderRadius.circular(AppRadius.formContainer),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Editar romaneio',
                  onBack: () => context.go(AppRoutes.romaneio),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Motorista / entregador',
                  controller: mc,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Placa',
                  controller: pc,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.input,
                    borderRadius: BorderRadius.circular(AppRadius.formContainer),
                    border: Border.all(color: AppColors.inputEnabledBorder),
                  ),
                  child: RomaneioCampoLogistica(
                    label: 'Total faturado',
                    value: 'R\$ ${formatarPreco(vm.totalFaturadoEdit)}',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Pedidos do romaneio',
                  style: AppTextStyles.sectionTitleSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: vm.isCarregandoPedidosParaAdicionar
                        ? null
                        : () => romaneioAbrirModalAdicionarPedido(context, vm),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar pedido'),
                  ),
                ),
                if (vm.pedidosEdit.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Text(
                      'Nenhum pedido. Use "Adicionar pedido" para incluir.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ...vm.pedidosEdit.map(
                    (p) => _RomaneioPedidoEdicaoRow(vm: vm, pedido: p),
                  ),
                if (vm.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    vm.errorMessage,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    FilledButton(
                      onPressed: vm.isSalvandoEdicao
                          ? null
                          : () async {
                              final ok = await vm.salvarEdicao();
                              if (!context.mounted) return;
                              if (ok) {
                                showAppToast(
                                  context,
                                  message: 'Romaneio atualizado.',
                                );
                              } else {
                                showAppToast(
                                  context,
                                  message: vm.errorMessage,
                                  isError: true,
                                );
                              }
                            },
                      child: vm.isSalvandoEdicao
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    TextButton(
                      onPressed: vm.isSalvandoEdicao
                          ? null
                          : () => vm.exitEditMode(),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RomaneioPedidoEdicaoRow extends StatelessWidget {
  const _RomaneioPedidoEdicaoRow({
    required this.vm,
    required this.pedido,
  });

  final RomaneioDetalheViewModel vm;
  final PedidoListagemModel pedido;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${vm.idPedidoFormatado(pedido)} — '
              '${vm.nomeClienteDoPedido(pedido.idPedido)}',
              style: AppTextStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            vm.valorFormatadoPedido(pedido),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.error,
            onPressed: () => vm.removerPedidoDoRomaneio(pedido),
            tooltip: 'Remover do romaneio',
          ),
        ],
      ),
    );
  }
}
