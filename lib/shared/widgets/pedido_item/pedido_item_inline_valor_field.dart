import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/utils/input_formatters.dart';

/// Campo de valor idêntico ao da tela de produtos (AppTextField com type moeda).
/// Ao ganhar foco, seleciona todo o texto para a digitação substituir e crescer da esquerda para a direita.
class PedidoItemInlineValorField extends StatelessWidget {
  const PedidoItemInlineValorField({
    super.key,
    required this.controller,
    this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;

  static OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
      borderSide: BorderSide(
        color: color ?? Colors.transparent,
        width: width,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'\d')),
        CurrencyInputFormatter(),
      ],
      style: TextStyle(color: AppColors.textPrimary),
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
