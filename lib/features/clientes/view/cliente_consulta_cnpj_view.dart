import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_criar_extra.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/cliente_consulta_cnpj_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_input_type.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_form_container.dart';
import 'package:erp_alianca_dev/shared/widgets/app_primary_button.dart';
import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';

class ClienteConsultaCnpjView extends StatelessWidget {
  const ClienteConsultaCnpjView({super.key});

  Future<void> _consultar(
    BuildContext context,
    ClienteConsultaCnpjViewModel vm,
  ) async {
    final dados = await vm.consultar();
    if (!context.mounted) return;
    if (dados == null) {
      final msg = vm.errorMessage;
      if (msg != null && msg.isNotEmpty) {
        showAppError(context, message: msg);
      }
      return;
    }

    context.go(
      AppRoutes.clientesCriar,
      extra: ClienteCriarExtra(
        consultaCnpj: dados,
        rotaVoltar: AppRoutes.clientesConsultaCnpj,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClienteConsultaCnpjViewModel>(
      builder: (context, vm, _) {
        final carregando = vm.state == ViewState.loading;

        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'CNPJ',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Informe o CNPJ para buscar os dados na Receita Federal '
                      'e cadastrar o cliente.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppFormContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            label: 'CNPJ',
                            controller: vm.cnpjController,
                            type: AppInputType.cnpj,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppPrimaryButton(
                            label: carregando ? 'Buscando...' : 'Buscar',
                            isLoading: carregando,
                            onPressed: vm.podeConsultar
                                ? () => _consultar(context, vm)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: carregando
                          ? null
                          : () => context.go(AppRoutes.clientes),
                      child: const Text('Voltar para listagem'),
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
}
