import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_create_action_bar.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_create_coluna_esquerda.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_create_coluna_pedidos.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Layout coluna única: Informações → Motorista → Resumo → Painel de pedidos → Barra de ação.
class RomaneioCreateLayoutSingleColumn extends StatelessWidget {
  const RomaneioCreateLayoutSingleColumn({super.key, required this.vm});

  final RomaneioCriarViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RomaneioCreateColunaEsquerdaContent(vm: vm),
                    const SizedBox(height: AppSpacing.sectionSpacingCompact),
                    RomaneioCreateColunaPedidos(vm: vm, useExpanded: false),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
        RomaneioCreateActionBar(vm: vm),
      ],
    );
  }
}
