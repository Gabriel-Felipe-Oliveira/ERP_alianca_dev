import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/cliente_editar_viewmodel.dart';
import 'package:erp_alianca_dev/features/clientes/view/widgets/cliente_form_fields.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_form_container.dart';
import 'package:erp_alianca_dev/shared/widgets/app_primary_button.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';
import 'package:erp_alianca_dev/shared/widgets/app_confirm_delete_dialog.dart';
import 'package:erp_alianca_dev/shared/widgets/app_loading_message.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tool_panel.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';

/// Tela de detalhes do cliente. Busca os dados pela API usando o id da rota.
/// Estrutura fixa: LayoutBuilder → Stack (scroll + painel). Só o conteúdo muda.
class ClienteDetalhesView extends StatefulWidget {
  const ClienteDetalhesView({super.key});

  @override
  State<ClienteDetalhesView> createState() => _ClienteDetalhesViewState();
}

class _ClienteDetalhesViewState extends State<ClienteDetalhesView>
    with SingleTickerProviderStateMixin {
  static const Duration _entranceDuration = Duration(milliseconds: 950);

  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;
  late final Animation<double> _entranceScale;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    );
    final curve = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.linear,
    );
    _entranceFade = curve;
    _entranceScale = Tween<double>(begin: 0.88, end: 1.0).animate(curve);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClienteEditarViewModel>(
      builder: (context, vm, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < AppSpacing.toolPanelBreakpoint;
            final rightPadding = compact
                ? AppSpacing.toolPanelWidthCompact + AppSpacing.lg + AppSpacing.sm
                : AppSpacing.toolPanelWidth + AppSpacing.lg * 2;

            return Stack(
              children: [
                RepaintBoundary(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: rightPadding,
                      vertical: AppSpacing.lg,
                    ),
                    child: Center(
                      child: ScaleTransition(
                        scale: _entranceScale,
                        alignment: Alignment.center,
                        child: FadeTransition(
                          opacity: _entranceFade,
                          child: _buildBody(context, vm),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: AppSpacing.lg,
                  top: 0,
                  bottom: 0,
                  child: RepaintBoundary(
                    child: Center(
                      child: _buildPanel(context, vm, compact),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Escolhe o corpo: loading, erro ou formulário.
  Widget _buildBody(BuildContext context, ClienteEditarViewModel vm) {
    if (vm.isLoading) return _buildLoadingBody();
    if (vm.loadError != null) return _buildErrorBody(vm);
    return _buildFormBody(context, vm);
  }

  /// Indicador simples de carregamento (sem skeleton).
  Widget _buildLoadingBody() {
    return const AppLoadingMessage();
  }

  /// Painel: desabilitado no loading, real após carregamento.
  Widget _buildPanel(BuildContext context, ClienteEditarViewModel vm, bool compact) {
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
        ],
      );
    }

    if (vm.loadError != null) return const SizedBox.shrink();

    return AppToolPanel(
      compact: compact,
      items: _buildToolPanelItems(context, vm),
    );
  }

  Widget _buildErrorBody(ClienteEditarViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 120),
        Text(
          vm.loadError!,
          style: AppTextStyles.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: () => vm.recarregar(),
          child: const Text('Tentar novamente'),
        ),
      ],
    );
  }

  Widget _buildFormBody(BuildContext context, ClienteEditarViewModel vm) {
    final editing = vm.isEditing;
    final c = vm.cliente!;
    final nomeEmpresa = c.nomeEmpresa?.trim();
    final mostraNomeEmpresa = nomeEmpresa != null && nomeEmpresa.isNotEmpty;
    final docFormatado = c.documentoFormatado;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SectionHeader(
          title: 'Detalhes do Cliente',
          description: c.nome,
          onBack: () => context.go(AppRoutes.clientes),
        ),
        if (mostraNomeEmpresa) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            nomeEmpresa,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (docFormatado != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            docFormatado,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppFormContainer(
          child: Form(
            key: vm.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...ClienteFormFields.buildFieldsForEditar(context, vm),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(vm.errorMessage!, style: AppTextStyles.error),
                ],
                if (editing) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(
                    label: 'Salvar',
                    onPressed: (vm.isValid && !vm.isSaving)
                        ? () => _aoSalvarEdicao(context, vm)
                        : null,
                    isLoading: vm.isSaving,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static bool _clienteEhInativo(ClienteModel? c) {
    if (c == null) return false;
    return c.status.trim().toLowerCase() == 'inativo';
  }

  static List<AppToolPanelItemConfig> _buildToolPanelItems(
    BuildContext context,
    ClienteEditarViewModel vm,
  ) {
    return [
      if (!_clienteEhInativo(vm.cliente) && vm.cliente?.id != null)
        AppToolPanelItemConfig(
          icon: Icons.add_shopping_cart,
          label: 'Criar pedido',
          isPrimary: true,
          enabled: !vm.isSaving,
          onTap: () => _irParaCriarPedido(context, vm),
          variant: AppToolPanelItemVariant.primaryFilled,
        ),
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
      if (_clienteEhInativo(vm.cliente))
        AppToolPanelItemConfig(
          icon: Icons.delete_outline,
          label: 'Excluir',
          isDestructive: true,
          enabled: !vm.isExcluindo,
          onTap: () => _mostrarDialogoExcluir(context, vm),
          variant: AppToolPanelItemVariant.danger,
        ),
    ];
  }

  static void _irParaCriarPedido(BuildContext context, ClienteEditarViewModel vm) {
    final cliente = vm.cliente;
    if (cliente == null) return;
    context.push(AppRoutes.pedidosCriar, extra: cliente);
  }

  static void _mostrarDialogoExcluir(BuildContext context, ClienteEditarViewModel vm) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AppConfirmDeleteDialog(
        title: 'Excluir cliente',
        contentMessage:
            'Tem certeza que deseja excluir este cliente? Esta ação arquiva o cadastro.',
        onConfirmar: () => _confirmarExclusao(ctx, context, vm),
        onCancelar: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  static Future<void> _confirmarExclusao(
    BuildContext dialogContext,
    BuildContext screenContext,
    ClienteEditarViewModel vm,
  ) async {
    final router = GoRouter.of(screenContext);
    final overlayState = Overlay.of(screenContext);
    Navigator.of(dialogContext).pop();
    final sucesso = await vm.excluir();
    if (!screenContext.mounted) return;
    if (sucesso) {
      showAppToast(screenContext, message: 'Cliente excluído com sucesso.', overlay: overlayState);
      router.go(AppRoutes.clientes);
      // Lista recarrega ao montar (initState na ClientesView).
    }
  }

  static Future<void> _aoSalvarEdicao(BuildContext context, ClienteEditarViewModel vm) async {
    final overlayState = Overlay.of(context);
    final sucesso = await vm.salvar();
    if (!context.mounted) return;
    if (sucesso) {
      showAppToast(context, message: 'Cliente atualizado com sucesso.', overlay: overlayState);
      // Permanece na tela de detalhes. Lista recarrega quando o usuário voltar (initState/didPopNext).
    }
  }
}
