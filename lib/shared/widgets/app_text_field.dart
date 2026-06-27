import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_input_type.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/utils/app_validators.dart';
import 'package:erp_alianca_dev/shared/utils/input_formatters.dart';

/// Campo de texto reutilizável do Design System para todos os CRUDs.
/// O [type] define formatação e validação (email, cep, estado).
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final AppInputType? type;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool obscureText;
  final bool isModified;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.type,
    this.validator,
    this.keyboardType,
    this.enabled = true,
    this.obscureText = false,
    this.isModified = false,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
  });

  static OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
      borderSide: BorderSide(
        color: color ?? Colors.transparent,
        width: width,
      ),
    );
  }

  List<TextInputFormatter>? _buildInputFormatters() {
    switch (type) {
      case AppInputType.cep:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'\d')),
          CepInputFormatter(),
        ];
      case AppInputType.estado:
        return [
          UpperCaseInputFormatter(),
          LengthLimitingTextInputFormatter(2),
        ];
      case AppInputType.telefoneDD:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'\d')),
          LengthLimitingTextInputFormatter(2),
        ];
      case AppInputType.telefoneNumero:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'\d')),
          LengthLimitingTextInputFormatter(9),
        ];
      case AppInputType.moeda:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'\d')),
          CurrencyInputFormatter(),
        ];
      case AppInputType.placaVeiculo:
        return [
          PlacaVeiculoInputFormatter(),
        ];
      case AppInputType.cpf:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'\d')),
          CpfInputFormatter(),
        ];
      case AppInputType.cnpj:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'\d')),
          CnpjInputFormatter(),
        ];
      default:
        return null;
    }
  }

  TextInputType _resolveKeyboardType() {
    if (keyboardType != null) return keyboardType!;
    switch (type) {
      case AppInputType.email:
        return TextInputType.emailAddress;
      case AppInputType.cep:
      case AppInputType.telefoneDD:
      case AppInputType.telefoneNumero:
      case AppInputType.moeda:
      case AppInputType.cpf:
      case AppInputType.cnpj:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  int? _resolveMaxLength() {
    if (maxLength != null) return maxLength;
    switch (type) {
      case AppInputType.estado:
      case AppInputType.telefoneDD:
        return 2;
      case AppInputType.cep:
        return 9; // 00000-000
      case AppInputType.telefoneNumero:
        return 9;
      case AppInputType.placaVeiculo:
        return 7;
      case AppInputType.cpf:
        return 14; // 000.000.000-00
      case AppInputType.cnpj:
        return 18; // 00.000.000/0000-00
      default:
        return null;
    }
  }

  String? Function(String?)? _resolveValidator() {
    if (validator != null) return validator;
    switch (type) {
      case AppInputType.email:
        return AppValidators.email;
      case AppInputType.cep:
        return AppValidators.cep;
      case AppInputType.estado:
        return AppValidators.estado;
      case AppInputType.telefoneDD:
        return AppValidators.telefoneDD;
      case AppInputType.telefoneNumero:
        return AppValidators.telefoneNumero;
      case AppInputType.moeda:
        return AppValidators.preco;
      case AppInputType.placaVeiculo:
        return AppValidators.placaVeiculo;
      case AppInputType.cpf:
        return AppValidators.cpf;
      case AppInputType.cnpj:
        return AppValidators.cnpj;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: _resolveValidator(),
      keyboardType: _resolveKeyboardType(),
      enabled: enabled,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: _resolveMaxLength(),
      onChanged: onChanged,
      inputFormatters: _buildInputFormatters(),
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isModified ? AppColors.primary : AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.input,
        border: _border(color: AppColors.inputEnabledBorder),
        enabledBorder: isModified
            ? _border(color: AppColors.primary, width: AppSpacing.inputFocusedBorderWidth)
            : _border(color: AppColors.inputEnabledBorder),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: AppSpacing.inputFocusedBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingHorizontal,
          vertical: AppSpacing.inputPaddingVertical,
        ),
      ),
    );
  }
}
