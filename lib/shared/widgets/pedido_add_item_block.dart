import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_total_as_text.dart';

/// Bloco para adicionar item ao pedido: produto (read-only), Valor / Quantidade / Total e botões.
/// Total é exibido como texto (sem input). Reutilizável em Criar Pedido e Detalhes do Pedido.
class PedidoAddItemBlock extends StatelessWidget {
  const PedidoAddItemBlock({
    super.key,
    required this.productNameController,
    required this.valorController,
    required this.quantidadeController,
    required this.totalValue,
    required this.onCancelar,
    required this.onAdicionar,
    this.adicionarLabel = 'Adicionar item',
  });

  final TextEditingController productNameController;
  final TextEditingController valorController;
  final TextEditingController quantidadeController;
  final String totalValue;
  final VoidCallback onCancelar;
  final VoidCallback onAdicionar;
  final String adicionarLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          label: 'Produto',
          controller: productNameController,
          enabled: false,
        ),
        const SizedBox(height: AppSpacing.fieldSpacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: AppTextField(
                label: 'Valor',
                controller: valorController,
                enabled: false,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 1,
              child: AppTextField(
                label: 'Quantidade',
                controller: quantidadeController,
                keyboardType: TextInputType.number,
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: AppTotalAsText(value: totalValue),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.fieldSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onCancelar,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              height: AppSpacing.buttonHeightSecondary,
              child: OutlinedButton(
                onPressed: onAdicionar,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryLight),
                  foregroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppSpacing.inputBorderRadius),
                  ),
                ),
                child: Text(adicionarLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
