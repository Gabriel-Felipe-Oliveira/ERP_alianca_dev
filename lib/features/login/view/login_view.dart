import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import 'package:erp_alianca_dev/core/constants/app_constants.dart';

import 'package:erp_alianca_dev/features/login/viewmodel/login_viewmodel.dart';

import 'package:erp_alianca_dev/routes/app_routes.dart';

import 'package:erp_alianca_dev/shared/models/base_state.dart';

import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

import 'package:erp_alianca_dev/shared/theme/app_input_type.dart';

import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

import 'package:erp_alianca_dev/shared/widgets/app_form_container.dart';

import 'package:erp_alianca_dev/shared/widgets/app_primary_button.dart';

import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';

import 'package:erp_alianca_dev/shared/widgets/app_theme_rebuild_child.dart';

import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';



class LoginView extends StatelessWidget {

  const LoginView({super.key});



  Future<void> _entrar(BuildContext context, LoginViewModel vm) async {

    final ok = await vm.entrar();

    if (!context.mounted) return;

    if (!ok) {

      final msg = vm.errorMessage;

      if (msg != null && msg.isNotEmpty) {

        showAppError(context, message: msg);

      }

      return;

    }

    context.go(AppRoutes.home);

  }



  @override

  Widget build(BuildContext context) {

    return Consumer<LoginViewModel>(

      builder: (context, vm, _) {

        final carregando = vm.state == ViewState.loading;



        return AppThemeRebuildChild(

          child: Scaffold(

            backgroundColor: AppColors.contentBackground,

            body: SizedBox(

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

                          AppConstants.appName,

                          textAlign: TextAlign.center,

                          style: AppTextStyles.heading2.copyWith(

                            color: AppColors.textPrimary,

                          ),

                        ),

                        const SizedBox(height: AppSpacing.sm),

                        Text(

                          'Entre com seu e-mail e senha para acessar o sistema.',

                          textAlign: TextAlign.center,

                          style: AppTextStyles.bodyMedium.copyWith(

                            color: AppColors.textSecondary,

                          ),

                        ),

                        const SizedBox(height: AppSpacing.xl),

                        AppFormContainer(

                          child: Form(

                            key: vm.formKey,

                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.stretch,

                              children: [

                                AppTextField(

                                  label: 'E-mail',

                                  controller: vm.emailController,

                                  type: AppInputType.email,

                                  textInputAction: TextInputAction.next,

                                ),

                                const SizedBox(height: AppSpacing.fieldSpacing),

                                AppTextField(

                                  label: 'Senha',

                                  controller: vm.senhaController,

                                  obscureText: true,

                                  textInputAction: TextInputAction.done,

                                  onFieldSubmitted: (_) {

                                    if (vm.podeEntrar && !carregando) {

                                      _entrar(context, vm);

                                    }

                                  },

                                ),

                                const SizedBox(height: AppSpacing.lg),

                                AppPrimaryButton(

                                  label: carregando ? 'Entrando...' : 'Entrar',

                                  isLoading: carregando,

                                  onPressed: vm.podeEntrar

                                      ? () => _entrar(context, vm)

                                      : null,

                                  onDisabledTap: vm.podeEntrar

                                      ? null

                                      : () => _entrar(context, vm),

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

        );

      },

    );

  }

}


