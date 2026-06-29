import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_alianca_dev/core/platform/windows_keyboard_fix.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_input_type.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/utils/app_validators.dart';
import 'package:erp_alianca_dev/shared/utils/input_formatters.dart';

/// Campo de texto reutilizável do Design System para todos os CRUDs.
class AppTextField extends StatefulWidget {
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
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
  });

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
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  FocusNode? _focusNode;
  bool _ownsFocusNode = true;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _bindFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _unbindFocusNode();
      _bindFocusNode(widget.focusNode);
    }
  }

  @override
  void dispose() {
    _unbindFocusNode();
    super.dispose();
  }

  void _bindFocusNode(FocusNode? external) {
    _ownsFocusNode = external == null;
    _focusNode = external ?? FocusNode();
    _focusNode!.addListener(_onFocusChange);
  }

  void _unbindFocusNode() {
    _focusNode?.removeListener(_onFocusChange);
    if (_ownsFocusNode) {
      _focusNode?.dispose();
    }
    _focusNode = null;
  }

  void _onFocusChange() {
    final hasFocus = _focusNode?.hasFocus ?? false;
    if (hasFocus && Platform.isWindows) {
      WindowsKeyboardFix.syncNow();
    }
    if (_focused != hasFocus && mounted) {
      setState(() => _focused = hasFocus);
    }
  }

  OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(
        color: color ?? Colors.transparent,
        width: width,
      ),
    );
  }

  List<TextInputFormatter>? _buildInputFormatters() {
    switch (widget.type) {
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
        return [PlacaVeiculoInputFormatter()];
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
    if (widget.keyboardType != null) return widget.keyboardType!;
    switch (widget.type) {
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
    if (widget.maxLength != null) return widget.maxLength;
    switch (widget.type) {
      case AppInputType.estado:
      case AppInputType.telefoneDD:
        return 2;
      case AppInputType.cep:
        return 9;
      case AppInputType.telefoneNumero:
        return 9;
      case AppInputType.placaVeiculo:
        return 7;
      case AppInputType.cpf:
        return 14;
      case AppInputType.cnpj:
        return 18;
      default:
        return null;
    }
  }

  String? Function(String?)? _resolveValidator() {
    if (widget.validator != null) return widget.validator;
    switch (widget.type) {
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
    final field = TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      validator: _resolveValidator(),
      keyboardType: _resolveKeyboardType(),
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
      obscureText: widget.obscureText,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: _resolveMaxLength(),
      onChanged: widget.onChanged,
      inputFormatters: _buildInputFormatters(),
      style: TextStyle(
        color: widget.enabled ? AppColors.textBody : AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          color: widget.isModified ? AppColors.primary : AppColors.textSecondary,
        ),
        filled: true,
        fillColor: widget.enabled
            ? AppColors.input
            : AppColors.sidebarItemBackground,
        border: _border(color: AppColors.inputEnabledBorder),
        enabledBorder: widget.isModified
            ? _border(color: AppColors.primary)
            : _border(color: AppColors.inputEnabledBorder),
        focusedBorder: _border(color: AppColors.primary, width: 1),
        errorBorder: _border(color: AppColors.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingHorizontal,
          vertical: AppSpacing.inputPaddingVertical,
        ),
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: _focused && AppColors.isLightTheme
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.input),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ],
            )
          : null,
      child: field,
    );
  }
}
