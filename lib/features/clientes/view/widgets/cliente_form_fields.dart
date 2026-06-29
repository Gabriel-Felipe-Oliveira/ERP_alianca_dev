import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/clientes/utils/cliente_validator.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/cliente_criar_viewmodel.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/cliente_editar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/theme/app_input_type.dart';
import 'package:erp_alianca_dev/shared/widgets/app_dropdown_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_telefone_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_text_field.dart';
import 'package:erp_alianca_dev/shared/widgets/app_section_title.dart';

/// Campos do formulário de cliente reutilizados em criar e editar.
/// Centraliza layout e usa [AppSpacing.fieldSpacing] / [AppSpacing.sectionSpacing] em ambos.
abstract class ClienteFormFields {
  static const double _fieldSpacing = AppSpacing.fieldSpacing;
  static const double _sectionSpacing = AppSpacing.sectionSpacing;

  /// Lista de widgets dos campos para a tela de criar cliente.
  static List<Widget> buildFieldsForCriar(ClienteCriarViewModel vm) {
    return [
      const AppSectionTitle(title: 'Dados Gerais'),
      const SizedBox(height: _fieldSpacing),
      AppTextField(
        label: vm.isCpf ? 'Nome completo' : 'Nome da empresa',
        controller: vm.nomeController,
        validator: ClienteValidator.nomeCriar(vm.isCpf),
      ),
      const SizedBox(height: _fieldSpacing),
      AppTelefoneField(
        ddController: vm.ddController,
        numeroController: vm.telefoneNumeroController,
      ),
      const SizedBox(height: _fieldSpacing),
      AppTextField(
        label: 'E-mail',
        controller: vm.emailController,
        type: AppInputType.email,
      ),
      const SizedBox(height: _fieldSpacing),
      Text(
        'Tipo de documento',
        style: AppTextStyles.sectionTitleSecondary,
      ),
      const SizedBox(height: _fieldSpacing),
      RadioGroup<bool>(
        groupValue: vm.isCpf,
        onChanged: (value) {
          if (value != null) vm.isCpf = value;
        },
        child: Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<bool>(
                  value: true,
                  activeColor: AppColors.primary,
                ),
                Text('CPF', style: AppTextStyles.bodyMedium),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<bool>(
                  value: false,
                  activeColor: AppColors.primary,
                ),
                Text('CNPJ', style: AppTextStyles.bodyMedium),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: _fieldSpacing),
      AppTextField(
        label: vm.isCpf ? 'CPF (opcional)' : 'CNPJ (opcional)',
        controller: vm.documentController,
        type: vm.isCpf ? AppInputType.cpf : AppInputType.cnpj,
        validator: ClienteValidator.documentoCriar(vm.isCpf),
      ),
      if (vm.deveExibirCampoNomeEmpresa) ...[
        const SizedBox(height: _fieldSpacing),
        AppTextField(
          label: 'Nome da empresa (opcional)',
          controller: vm.nomeEmpresaController,
        ),
      ],
      if (!vm.isCpf) ...[
        const SizedBox(height: _fieldSpacing),
        AppTextField(
          label: 'Nome do responsável (opcional)',
          controller: vm.nomeResponsavelController,
        ),
      ],
      const SizedBox(height: _fieldSpacing),
      const AppSectionTitle(title: 'Endereço'),
      AppTextField(
        label: 'Logradouro',
        controller: vm.logradouroController,
      ),
      const SizedBox(height: _fieldSpacing),
      Row(
        children: [
          Expanded(
            child: AppTextField(
              label: 'Número',
              controller: vm.numeroController,
              keyboardType: TextInputType.text,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppTextField(
              label: 'CEP',
              controller: vm.cepController,
              type: AppInputType.cep,
            ),
          ),
        ],
      ),
      const SizedBox(height: _fieldSpacing),
      AppTextField(
        label: 'Bairro',
        controller: vm.bairroController,
      ),
      const SizedBox(height: _fieldSpacing),
      Row(
        children: [
          Expanded(
            flex: 3,
            child: AppTextField(
              label: 'Cidade',
              controller: vm.cidadeController,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppTextField(
              label: 'Estado',
              controller: vm.estadoController,
              type: AppInputType.estado,
            ),
          ),
        ],
      ),
      const SizedBox(height: _sectionSpacing),
      const AppSectionTitle(title: 'Status'),
      AppDropdownField<String>(
        label: 'Status',
        value: vm.status,
        items: ClienteModel.statusOpcoes
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
        onChanged: (v) => vm.status = v ?? 'Ativo',
      ),
    ];
  }

  /// Lista de widgets dos campos para a tela de detalhes/editar cliente.
  static List<Widget> buildFieldsForEditar(
    BuildContext context,
    ClienteEditarViewModel vm,
  ) {
    final editing = vm.isEditing;
    final c = vm.cliente!;
    return [
      const AppSectionTitle(title: 'Dados Gerais'),
      const SizedBox(height: _fieldSpacing),
      AppTextField(
        label: 'Nome',
        controller: vm.nomeController,
        validator: ClienteValidator.nomeEditar,
        enabled: editing,
        isModified: editing && vm.nomeModificado,
      ),
      if (c.tipoDocumento == 'cnpj') ...[
        const SizedBox(height: _fieldSpacing),
        AppTextField(
          label: 'Nome da empresa (opcional)',
          controller: vm.nomeEmpresaController,
          enabled: editing,
          isModified: editing && vm.nomeEmpresaModificado,
        ),
      ],
      const SizedBox(height: _fieldSpacing),
      AppTextField(
        label: c.tipoDocumento == 'cnpj' ? 'CNPJ (opcional)' : 'CPF (opcional)',
        controller: vm.documentController,
        type: c.tipoDocumento == 'cnpj' ? AppInputType.cnpj : AppInputType.cpf,
        validator: ClienteValidator.documentoEditar(c.tipoDocumento),
        enabled: editing,
        isModified: editing && vm.documentModificado,
      ),
      const SizedBox(height: _fieldSpacing),
      AppTelefoneField(
        ddController: vm.ddController,
        numeroController: vm.telefoneNumeroController,
        enabled: editing,
        isDDModified: editing && vm.ddModificado,
        isNumeroModified: editing && vm.telefoneNumeroModificado,
      ),
      const SizedBox(height: _fieldSpacing),
      AppTextField(
        label: 'E-mail',
        controller: vm.emailController,
        type: AppInputType.email,
        enabled: editing,
        isModified: editing && vm.emailModificado,
      ),
      const SizedBox(height: _sectionSpacing),
      const AppSectionTitle(title: 'Endereço'),
      AppTextField(
        label: 'Logradouro',
        controller: vm.logradouroController,
        validator: ClienteValidator.logradouroEditar,
        enabled: editing,
        isModified: editing && vm.logradouroModificado,
      ),
      const SizedBox(height: _fieldSpacing),
      Row(
        children: [
          Expanded(
            child: AppTextField(
              label: 'Número',
              controller: vm.numeroController,
              keyboardType: TextInputType.text,
              validator: ClienteValidator.numeroEditar,
              enabled: editing,
              isModified: editing && vm.numeroModificado,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppTextField(
              label: 'CEP',
              controller: vm.cepController,
              type: AppInputType.cep,
              validator: ClienteValidator.cepEditar,
              enabled: editing,
              isModified: editing && vm.cepModificado,
            ),
          ),
        ],
      ),
      const SizedBox(height: _fieldSpacing),
      AppTextField(
        label: 'Bairro',
        controller: vm.bairroController,
        validator: ClienteValidator.bairroEditar,
        enabled: editing,
        isModified: editing && vm.bairroModificado,
      ),
      const SizedBox(height: _fieldSpacing),
      Row(
        children: [
          Expanded(
            flex: 3,
            child: AppTextField(
              label: 'Cidade',
              controller: vm.cidadeController,
              validator: ClienteValidator.cidadeEditar,
              enabled: editing,
              isModified: editing && vm.cidadeModificado,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppTextField(
              label: 'Estado',
              controller: vm.estadoController,
              type: AppInputType.estado,
              validator: ClienteValidator.estadoEditar,
              enabled: editing,
              isModified: editing && vm.estadoModificado,
            ),
          ),
        ],
      ),
      const SizedBox(height: _sectionSpacing),
      const AppSectionTitle(title: 'Status'),
      AppDropdownField<String>(
        label: 'Status',
        value: vm.status,
        isModified: editing && vm.statusModificado,
        items: ClienteModel.statusOpcoes
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
        onChanged: editing ? (v) => vm.status = v ?? 'Ativo' : null,
      ),
    ];
  }
}
