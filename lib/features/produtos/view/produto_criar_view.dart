import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produto_criar_viewmodel.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produtos_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/theme/app_input_type.dart';
import 'package:erp_alianca_dev/shared/utils/app_validators.dart';
import 'package:erp_alianca_dev/shared/widgets/app_dropdown_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_form_container.dart';
import 'package:erp_alianca_dev/shared/widgets/app_primary_button.dart';
import 'package:erp_alianca_dev/shared/widgets/app_section_title.dart';
import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';

class ProdutoCriarView extends StatefulWidget {
  const ProdutoCriarView({super.key});

  @override
  State<ProdutoCriarView> createState() => _ProdutoCriarViewState();
}

class _ProdutoCriarViewState extends State<ProdutoCriarView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProdutoCriarViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Center(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SectionHeader(
                    title: 'Criar Produto',
                    description: 'Preencha os dados para cadastrar um novo produto.',
                    onBack: () => context.go(AppRoutes.produtos),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFormContainer(
                    child: Form(
                      key: vm.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppSectionTitle(title: 'Dados do Produto'),
                          AppTextField(
                            label: 'Nome',
                            controller: vm.nomeController,
                            validator: (v) => AppValidators.obrigatorio(v, 'Nome'),
                          ),
                          const SizedBox(height: AppSpacing.fieldSpacing),
                          AppTextField(
                            label: 'Preço',
                            controller: vm.precoController,
                            type: AppInputType.moeda,
                          ),
                          const SizedBox(height: AppSpacing.fieldSpacing),
                          AppTextField(
                            label: 'Estoque atual (opcional)',
                            controller: vm.estoqueAtualController,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              return AppValidators.inteiroNaoNegativo(v, 'Estoque');
                            },
                          ),
                          const SizedBox(height: AppSpacing.sectionSpacing),
                          const AppSectionTitle(title: 'Status'),
                          AppDropdownField<String>(
                            label: 'Status',
                            value: vm.status,
                            items: ProdutoCriarViewModel.statusOpcoes
                                .map(
                                  (s) => DropdownMenuItem<String>(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => vm.status = v ?? 'ativo',
                          ),
                          if (vm.errorMessage != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              vm.errorMessage!,
                              style: AppTextStyles.error,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
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
        );
      },
    );
  }

  static Future<void> _aoCriar(
      BuildContext context, ProdutoCriarViewModel vm) async {
    final sucesso = await vm.salvar();
    if (!context.mounted) return;
    if (sucesso) {
      await context.read<ProdutosViewModel>().loadProdutos();
      if (!context.mounted) return;
      context.go(AppRoutes.produtos);
    }
  }

  static void _mostrarCamposFaltantes(
      BuildContext context, ProdutoCriarViewModel vm) {
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
}
