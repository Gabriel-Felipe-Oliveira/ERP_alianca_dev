import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_campo_logistica.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_detalhe_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Card de informações logísticas do romaneio.
class RomaneioDetalheLogisticaCard extends StatelessWidget {
  const RomaneioDetalheLogisticaCard({
    super.key,
    required this.vm,
    required this.romaneio,
  });

  final RomaneioDetalheViewModel vm;
  final RomaneioModel romaneio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(AppRadius.formContainer),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações logísticas',
            style: AppTextStyles.sectionTitleSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RomaneioCampoLogistica(
                  label: 'Placa',
                  value: vm.placaExibicao(romaneio),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: RomaneioCampoLogistica(
                  label: 'Motorista',
                  value: vm.motoristaExibicao(romaneio),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          RomaneioCampoLogistica(
            label: 'Quantidade de pedidos',
            value: '${romaneio.quantidadePedidos} pedido(s)',
          ),
        ],
      ),
    );
  }
}
