import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Diálogo que exige digitar uma palavra (ex.: "DELETE") para confirmar exclusão.
/// Reutilizável em clientes, produtos e outras entidades.
class AppConfirmDeleteDialog extends StatefulWidget {
  const AppConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.contentMessage,
    required this.onConfirmar,
    required this.onCancelar,
    this.confirmationWord = 'DELETE',
    this.confirmButtonLabel = 'Confirmar exclusão',
  });

  final String title;
  final String contentMessage;
  final VoidCallback onConfirmar;
  final VoidCallback onCancelar;
  final String confirmationWord;
  final String confirmButtonLabel;

  @override
  State<AppConfirmDeleteDialog> createState() => _AppConfirmDeleteDialogState();
}

class _AppConfirmDeleteDialogState extends State<AppConfirmDeleteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _podeConfirmar =>
      _controller.text.trim().toUpperCase() == widget.confirmationWord.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.contentMessage),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Digite ${widget.confirmationWord} para confirmar:',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.confirmationWord,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancelar,
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _podeConfirmar ? widget.onConfirmar : null,
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: Text(widget.confirmButtonLabel),
        ),
      ],
    );
  }
}
