import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Botões de edição/confirmação/cancelamento da linha de item do pedido.
class PedidoItemRowActions extends StatelessWidget {
  const PedidoItemRowActions({
    super.key,
    required this.estaEmEdicao,
    this.onConfirmar,
    this.onCancelar,
    this.onEditar,
  });

  final bool estaEmEdicao;
  final VoidCallback? onConfirmar;
  final VoidCallback? onCancelar;
  final VoidCallback? onEditar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (estaEmEdicao) ...[
          if (onConfirmar != null)
            FilledButton(
              onPressed: onConfirmar,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 28),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
              ),
              child: const Text('Confirmar'),
            ),
          if (onConfirmar != null && onCancelar != null)
            const SizedBox(width: AppSpacing.sm),
          if (onCancelar != null)
            TextButton(
              onPressed: onCancelar,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 28),
              ),
              child: const Text('Cancelar'),
            ),
        ] else if (onEditar != null)
          TextButton(
            onPressed: onEditar,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 28),
            ),
            child: const Text('Editar quantidade'),
          ),
      ],
    );
  }
}
