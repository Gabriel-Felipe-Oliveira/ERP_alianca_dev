import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Diálogo que exige digitar "delete" para confirmar exclusão.
class ProdutoDetalheDialogoExclusao extends StatefulWidget {
  const ProdutoDetalheDialogoExclusao({
    super.key,
    required this.onConfirmar,
    required this.onCancelar,
  });

  final VoidCallback onConfirmar;
  final VoidCallback onCancelar;

  @override
  State<ProdutoDetalheDialogoExclusao> createState() =>
      _ProdutoDetalheDialogoExclusaoState();
}

class _ProdutoDetalheDialogoExclusaoState
    extends State<ProdutoDetalheDialogoExclusao> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _podeConfirmar => _controller.text.trim().toLowerCase() == 'delete';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir produto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tem certeza que deseja excluir este produto? Esta ação arquiva o cadastro.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Digite delete para confirmar:',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'delete',
              border: OutlineInputBorder(),
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
          child: const Text('Confirmar exclusão'),
        ),
      ],
    );
  }
}
