import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/utils/input_formatters.dart';

/// Campo de valor idêntico ao da tela de produtos (AppTextField com type moeda).
/// Ao ganhar foco, seleciona todo o texto para a digitação substituir e crescer da esquerda para a direita.
class PedidoItemInlineValorField extends StatefulWidget {
  const PedidoItemInlineValorField({
    super.key,
    required this.controller,
    this.focusNode,
    this.autoFitFontSize = false,
    this.compact = false,
    this.baseFontSize = 14,
    this.minFontSize = 9,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autoFitFontSize;
  final bool compact;
  final double baseFontSize;
  final double minFontSize;

  @override
  State<PedidoItemInlineValorField> createState() =>
      _PedidoItemInlineValorFieldState();
}

class _PedidoItemInlineValorFieldState extends State<PedidoItemInlineValorField> {
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
  void initState() {
    super.initState();
    if (widget.autoFitFontSize) {
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void didUpdateWidget(PedidoItemInlineValorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      if (widget.autoFitFontSize) {
        widget.controller.addListener(_onTextChanged);
      }
    } else if (oldWidget.autoFitFontSize != widget.autoFitFontSize) {
      if (widget.autoFitFontSize) {
        widget.controller.addListener(_onTextChanged);
      } else {
        widget.controller.removeListener(_onTextChanged);
      }
    }
  }

  @override
  void dispose() {
    if (widget.autoFitFontSize) {
      widget.controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  double _fontSizeForWidth(double maxWidth) {
    final text =
        widget.controller.text.trim().isEmpty ? '0,00' : widget.controller.text;
    var size = widget.baseFontSize;
    while (size > widget.minFontSize) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: double.infinity);
      if (painter.width <= maxWidth) {
        return size;
      }
      size -= 0.5;
    }
    return widget.minFontSize;
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.compact ? 10.0 : AppSpacing.inputPaddingHorizontal;
    final verticalPadding = widget.compact ? 8.0 : AppSpacing.inputPaddingVertical;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = widget.autoFitFontSize
            ? _fontSizeForWidth(
                (constraints.maxWidth - (horizontalPadding * 2))
                    .clamp(24, double.infinity),
              )
            : widget.baseFontSize;

        return TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'\d')),
            CurrencyInputFormatter(),
          ],
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: widget.compact,
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
          ),
        );
      },
    );
  }
}
