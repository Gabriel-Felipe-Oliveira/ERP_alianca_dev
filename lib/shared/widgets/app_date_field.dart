import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';
import 'package:erp_alianca_dev/shared/utils/input_formatters.dart';

/// Campo de data editável (dd/MM/yyyy) com botão de calendário à direita.
class AppDateField extends StatefulWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<AppDateField> createState() => _AppDateFieldState();
}

class _AppDateFieldState extends State<AppDateField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _textFromValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant AppDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final text = _textFromValue(widget.value);
      if (_controller.text != text) {
        _controller.text = text;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _textFromValue(DateTime? value) =>
      value != null ? formatarData(value) : '';

  Future<void> _pickDate() async {
    if (!widget.enabled) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? now,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? now,
      locale: const Locale('pt', 'BR'),
    );
    if (picked == null) return;
    _controller.text = formatarData(picked);
    widget.onChanged(picked);
  }

  void _onTextChanged(String text) {
    if (text.trim().isEmpty) {
      widget.onChanged(null);
      return;
    }
    if (text.length != 10) return;
    widget.onChanged(parseDataNascimentoApi(text));
  }

  @override
  Widget build(BuildContext context) {
    const radius = AppRadius.input;
    final leftRadius = BorderRadius.only(
      topLeft: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
    );
    final rightRadius = BorderRadius.only(
      topRight: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
                DateInputFormatter(),
              ],
              onChanged: _onTextChanged,
              style: TextStyle(
                color: widget.enabled
                    ? AppColors.textBody
                    : AppColors.textSecondary,
              ),
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: 'dd/MM/aaaa',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: widget.enabled
                    ? AppColors.input
                    : AppColors.sidebarItemBackground,
                border: OutlineInputBorder(
                  borderRadius: leftRadius,
                  borderSide: BorderSide(color: AppColors.inputEnabledBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: leftRadius,
                  borderSide: BorderSide(color: AppColors.inputEnabledBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: leftRadius,
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: leftRadius,
                  borderSide: BorderSide(color: AppColors.error),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.inputPaddingHorizontal,
                  vertical: AppSpacing.inputPaddingVertical,
                ),
              ),
            ),
          ),
          Material(
            color: widget.enabled
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.5),
            borderRadius: rightRadius,
            child: InkWell(
              onTap: widget.enabled ? _pickDate : null,
              borderRadius: rightRadius,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
