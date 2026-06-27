import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';

/// Resumo compacto: mesma cor base da sidebar, divisores finos, valor total em destaque.
class RomaneioResumoCard extends StatelessWidget {
  const RomaneioResumoCard({super.key, required this.vm});

  final RomaneioCriarViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pedidos selecionados: ${vm.quantidadePedidos}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Valor total: R\$ ${formatarPreco(vm.valorTotal)}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: AppColors.cardBorder, thickness: 1),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Volume total: ${vm.volumeTotal}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: AppColors.cardBorder, thickness: 1),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Motorista',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tipo: ${vm.tipoMotorista.label}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (vm.tipoMotorista == TipoMotorista.proprio) ...[
            const SizedBox(height: 2),
            Text(
              'Nome: ${vm.nomeMotoristaController.text.trim().isEmpty ? "—" : vm.nomeMotoristaController.text.trim()}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Placa: ${vm.placaVeiculoController.text.trim().isEmpty ? "—" : vm.placaVeiculoController.text.trim()}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: AppColors.cardBorder, thickness: 1),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Data: ${formatarData(vm.dataCriacao)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
