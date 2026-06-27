import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produto_editar_viewmodel.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produtos_viewmodel.dart';
import 'package:erp_alianca_dev/features/produtos/view/widgets/produto_detalhe/produto_detalhe_dialogo_exclusao.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tool_panel.dart';

/// Painel lateral de ações da tela de detalhes do produto.
class ProdutoDetalheToolPanel extends StatelessWidget {
  const ProdutoDetalheToolPanel({
    super.key,
    required this.vm,
    required this.compact,
  });

  final ProdutoEditarViewModel vm;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return AppToolPanel(
        compact: compact,
        items: [
          AppToolPanelItemConfig(
            icon: Icons.edit_outlined,
            label: 'Editar',
            enabled: false,
            onTap: () {},
          ),
          AppToolPanelItemConfig(
            icon: Icons.delete_outline,
            label: 'Excluir',
            isDestructive: true,
            enabled: false,
            onTap: () {},
          ),
        ],
      );
    }

    if (vm.loadError != null) return const SizedBox.shrink();

    return AppToolPanel(
      compact: compact,
      items: _buildToolPanelItems(context, vm),
    );
  }

  static List<AppToolPanelItemConfig> _buildToolPanelItems(
    BuildContext context,
    ProdutoEditarViewModel vm,
  ) {
    return [
      if (vm.isEditing)
        AppToolPanelItemConfig(
          icon: Icons.close,
          label: 'Cancelar',
          isPrimary: true,
          enabled: !vm.isSaving,
          onTap: () => vm.cancelarEdicao(),
        )
      else
        AppToolPanelItemConfig(
          icon: Icons.edit_outlined,
          label: 'Editar',
          enabled: !vm.isSaving,
          onTap: () => vm.ativarEdicao(),
        ),
      AppToolPanelItemConfig(
        icon: Icons.delete_outline,
        label: 'Excluir',
        isDestructive: true,
        enabled: !vm.isExcluindo,
        onTap: () => _mostrarDialogoExcluir(context, vm),
      ),
    ];
  }

  static void _mostrarDialogoExcluir(
    BuildContext context,
    ProdutoEditarViewModel vm,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ProdutoDetalheDialogoExclusao(
        onConfirmar: () => _confirmarExclusao(ctx, context, vm),
        onCancelar: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  static Future<void> _confirmarExclusao(
    BuildContext dialogContext,
    BuildContext screenContext,
    ProdutoEditarViewModel vm,
  ) async {
    final overlayState = Overlay.of(screenContext);
    final produtosVm = screenContext.read<ProdutosViewModel>();
    Navigator.of(dialogContext).pop();
    final sucesso = await vm.excluir();
    if (!screenContext.mounted) return;
    if (sucesso) {
      showAppToast(
        screenContext,
        message: 'Produto arquivado com sucesso.',
        overlay: overlayState,
      );
      produtosVm.loadProdutos();
      GoRouter.of(screenContext).go(AppRoutes.produtos);
    }
  }
}
