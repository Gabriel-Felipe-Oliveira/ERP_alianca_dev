import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produto_editar_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_input_type.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/app_validators.dart';
import 'package:erp_alianca_dev/shared/widgets/app_dropdown_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_form_container.dart';
import 'package:erp_alianca_dev/shared/widgets/app_primary_button.dart';
import 'package:erp_alianca_dev/shared/widgets/app_section_title.dart';
import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';

/// Formulário de detalhes/edição do produto.
class ProdutoDetalheFormBody extends StatelessWidget {
  const ProdutoDetalheFormBody({
    super.key,
    required this.vm,
  });

  final ProdutoEditarViewModel vm;

  @override
  Widget build(BuildContext context) {
    final p = vm.produto!;
    final editing = vm.isEditing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SectionHeader(
          title: 'Detalhes do Produto',
          description: p.nome,
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
                  enabled: editing,
                  isModified: editing && vm.nomeModificado,
                ),
                const SizedBox(height: AppSpacing.fieldSpacing),
                AppTextField(
                  label: 'Preço',
                  controller: vm.precoController,
                  type: editing ? AppInputType.moeda : AppInputType.text,
                  enabled: editing,
                  isModified: editing && vm.precoModificado,
                ),
                const SizedBox(height: AppSpacing.fieldSpacing),
                AppTextField(
                  label: 'Estoque atual',
                  controller: vm.estoqueController,
                  keyboardType: TextInputType.number,
                  enabled: false,
                ),
                const SizedBox(height: AppSpacing.sectionSpacing),
                const AppSectionTitle(title: 'Status'),
                AppDropdownField<String>(
                  label: 'Status',
                  value: vm.status,
                  isModified: editing && vm.statusModificado,
                  items: ProdutoEditarViewModel.statusOpcoes
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
                  onChanged: editing ? (v) => vm.status = v ?? 'ativo' : null,
                ),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(vm.errorMessage!, style: AppTextStyles.error),
                ],
                if (editing) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(
                    label: 'Confirmar edição',
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

  static Future<void> _aoSalvarEdicao(
    BuildContext context,
    ProdutoEditarViewModel vm,
  ) async {
    final overlayState = Overlay.of(context);
    final sucesso = await vm.salvar();
    if (!context.mounted) return;
    if (sucesso) {
      showAppToast(
        context,
        message: 'Produto atualizado com sucesso.',
        overlay: overlayState,
      );
    }
  }
}
