import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Campo de quantidade inline (apenas número, com borda e estado de foco).
class PedidoItemInlineQtdField extends StatelessWidget {
  const PedidoItemInlineQtdField({
    super.key,
    required this.controller,
    this.fontSize = 14,
  });

  final TextEditingController controller;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      decoration: BoxDecoration(
        color: AppColors.sidebarItemBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'\d')),
        ],
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          hintText: '0',
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
