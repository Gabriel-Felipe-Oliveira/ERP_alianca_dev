import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_create_action_bar.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_create_coluna_esquerda.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_create_coluna_pedidos.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_create_layout_mode.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Layout duas colunas: esquerda (form + resumo + barra) e direita (pedidos).
class RomaneioCreateLayoutTwoColumns extends StatelessWidget {
  const RomaneioCreateLayoutTwoColumns({
    super.key,
    required this.vm,
    required this.mode,
  });

  final RomaneioCriarViewModel vm;
  final RomaneioCreateLayoutMode mode;

  @override
  Widget build(BuildContext context) {
    final flexLeft = mode == RomaneioCreateLayoutMode.medium ? 4 : 1;
    final flexRight = mode == RomaneioCreateLayoutMode.medium ? 5 : 1;
    final gap = mode == RomaneioCreateLayoutMode.medium ? AppSpacing.sm : AppSpacing.md;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: flexLeft,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
                      child: RomaneioCreateColunaEsquerdaContent(vm: vm),
                    ),
                  ),
                ),
              ),
              RomaneioCreateActionBar(vm: vm),
            ],
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          flex: flexRight,
          child: RomaneioCreateColunaPedidos(vm: vm, useExpanded: true),
        ),
      ],
    );
  }
}
