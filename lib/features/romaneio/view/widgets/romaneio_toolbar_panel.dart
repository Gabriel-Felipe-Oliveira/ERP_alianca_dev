import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_detalhe_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tool_panel.dart';

/// Painel lateral de ações do romaneio (faturar, PDF, editar, cancelar, excluir).
class RomaneioToolbarPanel extends StatelessWidget {
  const RomaneioToolbarPanel({
    super.key,
    required this.vm,
    required this.romaneio,
    required this.compact,
    required this.actionInProgress,
    required this.onFaturar,
    required this.onVisualizarPdf,
    required this.onGerarPdf,
    required this.onEditar,
    required this.onCancelar,
    required this.onExcluir,
  });

  final RomaneioDetalheViewModel vm;
  final RomaneioModel romaneio;
  final bool compact;
  final String? actionInProgress;
  final VoidCallback onFaturar;
  final VoidCallback onVisualizarPdf;
  final VoidCallback onGerarPdf;
  final VoidCallback onEditar;
  final VoidCallback onCancelar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final podePdf = vm.podeGerarPdf;
    final podeFaturar = vm.podeFaturar;
    final bloqueado = actionInProgress != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (actionInProgress != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.toolPanelBorderRadius),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    'Processando: $actionInProgress...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        AppToolPanel(
          compact: compact,
          items: [
            AppToolPanelItemConfig(
              icon: Icons.print_outlined,
              label: 'Faturar',
              variant: AppToolPanelItemVariant.primaryOnDark,
              enabled: podeFaturar && !bloqueado,
              onTap: onFaturar,
            ),
            AppToolPanelItemConfig(
              icon: Icons.picture_as_pdf_outlined,
              label: 'Visualizar PDF',
              variant: AppToolPanelItemVariant.neutral,
              enabled: podePdf && !bloqueado,
              onTap: onVisualizarPdf,
            ),
            AppToolPanelItemConfig(
              icon: Icons.save_outlined,
              label: 'Gerar PDF',
              variant: AppToolPanelItemVariant.neutral,
              enabled: podePdf && !bloqueado,
              onTap: onGerarPdf,
            ),
            if (romaneio.status == RomaneioStatus.rascunho)
              AppToolPanelItemConfig(
                icon: Icons.check_circle_outline,
                label: 'Editar romaneio',
                variant: AppToolPanelItemVariant.success,
                enabled: !bloqueado,
                onTap: onEditar,
              ),
            if (romaneio.status == RomaneioStatus.rascunho)
              AppToolPanelItemConfig(
                icon: Icons.cancel_outlined,
                label: 'Cancelar romaneio',
                variant: AppToolPanelItemVariant.danger,
                enabled: !vm.isAlterandoStatus && !bloqueado,
                onTap: onCancelar,
              ),
            if (romaneio.status == RomaneioStatus.cancelado)
              AppToolPanelItemConfig(
                icon: Icons.delete_outline,
                label: 'Excluir romaneio',
                variant: AppToolPanelItemVariant.danger,
                enabled: !vm.isArquivando && !bloqueado,
                onTap: onExcluir,
              ),
          ],
        ),
      ],
    );
  }
}
