import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Campo unificado: área de busca + botão "Escolher Cliente" em um único controle.
class PedidoCriarClienteSelector extends StatelessWidget {
  const PedidoCriarClienteSelector({
    super.key,
    required this.onEscolherCliente,
    this.textoExibido,
    this.hint = 'Buscar cliente por nome, telefone ou CPF/CNPJ...',
  });

  final VoidCallback onEscolherCliente;
  final String? textoExibido;
  final String hint;

  static const double _altura = 48;

  @override
  Widget build(BuildContext context) {
    final temCliente = textoExibido != null && textoExibido!.trim().isNotEmpty;

    return Material(
      color: AppColors.input,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: _altura,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inputEnabledBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onEscolherCliente,
                child: SizedBox(
                  height: _altura,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            temCliente ? textoExibido! : hint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: temCliente
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: _altura,
              color: AppColors.cardBorder.withValues(alpha: 0.7),
            ),
            Material(
              color: AppColors.primary,
              child: InkWell(
                onTap: onEscolherCliente,
                child: SizedBox(
                  height: _altura,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_add_alt_1,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Escolher Cliente',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
