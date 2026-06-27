import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/model/forma_pagamento_pedido.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Dropdown de forma de pagamento com placeholder interno (Criar Pedido).
class PedidoCriarFormaPagamentoField extends StatelessWidget {
  const PedidoCriarFormaPagamentoField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
      borderSide: BorderSide(
        color: color ?? Colors.transparent,
        width: width,
      ),
    );
  }

  String _labelItem(String interno) {
    switch (interno) {
      case 'pix':
        return 'Pix';
      case 'dinheiro':
        return 'Dinheiro';
      case 'cartão de crédito':
        return 'Cartão de crédito';
      default:
        return interno;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selecionado = value.trim().isEmpty ? null : value;

    return DropdownButtonFormField<String>(
      initialValue: selecionado,
      hint: Text(
        'Selecione a forma de pagamento',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      items: FormaPagamentoPedido.valoresInternos
          .where((v) => v.isNotEmpty)
          .map(
            (forma) => DropdownMenuItem<String>(
              value: forma,
              child: Text(
                _labelItem(forma),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (novo) {
        if (novo != null) onChanged(novo);
      },
      dropdownColor: AppColors.input,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.input,
        border: _border(color: AppColors.inputEnabledBorder),
        enabledBorder: _border(color: AppColors.inputEnabledBorder),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: AppSpacing.inputFocusedBorderWidth,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingHorizontal,
          vertical: AppSpacing.inputPaddingVertical,
        ),
      ),
    );
  }
}
