import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/cliente_criar_viewmodel.dart';
import 'package:erp_alianca_dev/features/clientes/view/widgets/cliente_form_fields.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_form_container.dart';
import 'package:erp_alianca_dev/shared/widgets/app_primary_button.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tool_panel.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';

class ClienteCriarView extends StatefulWidget {
  const ClienteCriarView({super.key});

  @override
  State<ClienteCriarView> createState() => _ClienteCriarViewState();
}

class _ClienteCriarViewState extends State<ClienteCriarView>
    with SingleTickerProviderStateMixin {
  static const Duration _entranceDuration = Duration(milliseconds: 950);

  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;
  late final Animation<double> _entranceScale;
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClienteCriarViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: PopScope(
            canPop: !vm.hasChanges,
            onPopInvokedWithResult: (bool didPop, dynamic result) {
              if (didPop) return;
              _mostrarDialogoSairSemSalvar(context, vm);
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < AppSpacing.toolPanelBreakpoint;
                final rightPadding = compact
                    ? AppSpacing.toolPanelWidthCompact + AppSpacing.md + AppSpacing.xs
                    : AppSpacing.toolPanelWidth + AppSpacing.md;
                return Stack(
                  children: [
                    RepaintBoundary(
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: rightPadding,
                            vertical: AppSpacing.sm,
                          ),
                          child: Center(
                            child: ScaleTransition(
                              scale: _entranceScale,
                              alignment: Alignment.center,
                              child: FadeTransition(
                                opacity: _entranceFade,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                SectionHeader(
                                  title: 'Criar Cliente',
                                  description: vm.veioDeConsultaCnpj
                                      ? 'Revise os dados da Receita Federal e cadastre o cliente.'
                                      : 'Preencha os dados para cadastrar um novo cliente.',
                                  onBack: () => context.go(vm.rotaVoltar),
                                ),
                                if (vm.temClienteCopiado)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppSpacing.sm,
                                      bottom: AppSpacing.xs,
                                    ),
                                    child: Text(
                                      'Dados copiados. Você pode colar aqui ou em outra planilha.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.xs),
                                AppFormContainer(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Form(
                                    key: vm.formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ...ClienteFormFields.buildFieldsForCriar(vm),
                                        const SizedBox(height: AppSpacing.md),
                                        AppPrimaryButton(
                                      label: 'Criar',
                                      onPressed: (vm.isValid && !vm.isLoading)
                                          ? () => _aoCriar(context, vm)
                                          : null,
                                      onDisabledTap: (vm.isValid || vm.isLoading)
                                          ? null
                                          : () => _mostrarCamposFaltantes(context, vm),
                                      isLoading: vm.isLoading,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                              ],
                            ),
                          ),
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
                          child: AppToolPanel(
                            items: _buildClienteToolPanelItems(context, vm),
                            compact: compact,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  static Future<void> _aoCriar(BuildContext context, ClienteCriarViewModel vm) async {
    final sucesso = await vm.salvar();
    if (!context.mounted) return;
    if (sucesso) {
      final clientePedido = vm.takeClienteParaPedido();
      showAppToast(context, message: 'Cliente criado com sucesso.');
      if (clientePedido != null) {
        context.go(AppRoutes.pedidosCriar, extra: clientePedido);
      } else {
        context.go(AppRoutes.clientes);
      }
    }
  }

  static void _mostrarCamposFaltantes(
      BuildContext context, ClienteCriarViewModel vm) {
    vm.formKey.currentState?.validate();
    final faltantes = vm.camposFaltantes;
    if (faltantes.isEmpty) return;
    showAppToast(
      context,
      message: 'Preencha: ${faltantes.join(', ')}.',
      isError: true,
      duration: const Duration(seconds: 3),
    );
  }

  static List<AppToolPanelItemConfig> _buildClienteToolPanelItems(
    BuildContext context,
    ClienteCriarViewModel vm,
  ) {
    return [
      AppToolPanelItemConfig(
        icon: Icons.copy,
        label: 'Copiar',
        onTap: () => _aoCopiar(context, vm),
      ),
      AppToolPanelItemConfig(
        icon: Icons.paste,
        label: 'Colar',
        onTap: () => _aoColar(context, vm),
      ),
      AppToolPanelItemConfig(
        icon: Icons.delete_outline,
        label: 'Limpar',
        isDestructive: true,
        onTap: () => _mostrarDialogoLimpar(context, vm),
      ),
    ];
  }

  static void _aoCopiar(BuildContext context, ClienteCriarViewModel vm) {
    vm.copiarFormulario();
    showAppToast(
      context,
      message: 'Dados copiados. Você pode colar aqui ou em outra planilha.',
    );
  }

  static Future<void> _aoColar(BuildContext context, ClienteCriarViewModel vm) async {
    final colou = await vm.colarFormulario();
    if (!context.mounted) return;
    if (colou) {
      showAppToast(
        context,
        message: 'Dados colados. Formulário preenchido com os dados do clipboard.',
      );
    } else {
      showAppToast(
        context,
        message:
            'Nenhum dado de cliente no clipboard. Copie primeiro nesta tela ou use um texto no formato esperado.',
        isError: true,
      );
    }
  }

  static void _mostrarDialogoLimpar(BuildContext context, ClienteCriarViewModel vm) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar formulário'),
        content: const Text(
          'Tem certeza que deseja limpar todos os campos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              vm.limparFormulario();
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  static void _mostrarDialogoSairSemSalvar(BuildContext context, ClienteCriarViewModel vm) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterações não salvas'),
        content: const Text(
          'Você possui alterações não salvas. Deseja sair mesmo assim?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              vm.limparFormulario();
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Sair sem salvar'),
          ),
        ],
      ),
    ).then((sair) {
      if (sair == true && context.mounted) {
        context.go(vm.rotaVoltar);
      }
    });
  }
}
