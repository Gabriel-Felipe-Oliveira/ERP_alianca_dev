import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Dropdown reutilizável do Design System (mesmo padrão visual do input).
class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool isModified;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.isModified = false,
  });

  static OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(
        color: color ?? Colors.transparent,
        width: width,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator != null ? (v) => validator!(v) : null,
      dropdownColor: AppColors.input,
      style: TextStyle(color: AppColors.textBody),
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
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
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
