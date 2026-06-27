import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_criar_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';
import 'package:erp_alianca_dev/shared/widgets/app_primary_button.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';

/// Barra inferior: mesma largura do painel esquerdo, cor da sidebar, divisor superior fino.
class RomaneioCreateActionBar extends StatelessWidget {
  const RomaneioCreateActionBar({super.key, required this.vm});

  final RomaneioCriarViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm + 4,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.sidebarBackground,
            border: Border(
              top: BorderSide(color: AppColors.cardBorder, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Pedidos: ${vm.quantidadePedidos}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Flexible(
                        child: Text(
                          'Total: R\$ ${formatarPreco(vm.valorTotal)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.go(AppRoutes.romaneio),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, AppSpacing.buttonHeightSecondary),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            side: BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppPrimaryButton(
                          label: 'Criar Romaneio',
                          isLoading: vm.isLoading,
                          onPressed: (vm.podeCriar && !vm.isLoading)
                              ? () => aoCriarRomaneio(context, vm)
                              : null,
                          onDisabledTap: (vm.podeCriar || vm.isLoading)
                              ? null
                              : () => mostrarCamposFaltantesRomaneioCreate(context, vm),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> aoCriarRomaneio(
  BuildContext context,
  RomaneioCriarViewModel vm,
) async {
  final sucesso = await vm.criarRomaneio();
  if (!context.mounted) return;
  if (sucesso) {
    showAppToast(context, message: 'Romaneio criado com sucesso.');
    context.go(AppRoutes.romaneio);
  }
}

void mostrarCamposFaltantesRomaneioCreate(
  BuildContext context,
  RomaneioCriarViewModel vm,
) {
  final faltantes = vm.camposFaltantes;
  if (faltantes.isEmpty) return;
  showAppToast(
    context,
    message: 'Complete: ${faltantes.join(', ')}.',
    isError: true,
    duration: const Duration(seconds: 3),
  );
}
