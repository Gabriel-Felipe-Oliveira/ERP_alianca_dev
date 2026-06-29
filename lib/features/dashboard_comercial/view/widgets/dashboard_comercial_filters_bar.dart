import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/model/dashboard_comercial_model.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/utils/dashboard_comercial_formatters.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/viewmodel/dashboard_comercial_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

class DashboardComercialFiltersBar extends StatelessWidget {
  const DashboardComercialFiltersBar({
    super.key,
    required this.vm,
    required this.onApply,
  });

  final DashboardComercialViewModel vm;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.formContainer),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardBoxShadow,
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _DateFilterChip(
            label: 'De',
            date: vm.dataInicio,
            onPick: () => _pickDate(context, vm.dataInicio, vm.setDataInicio),
          ),
          _DateFilterChip(
            label: 'Até',
            date: vm.dataFim,
            onPick: () => _pickDate(context, vm.dataFim, vm.setDataFim),
          ),
          _DropdownFilter<String>(
            label: 'Agrupamento',
            value: vm.agrupamento,
            items: kDashboardAgrupamentos
                .map((e) => DropdownMenuItem(value: e.value, child: Text(e.label)))
                .toList(),
            onChanged: vm.setAgrupamento,
          ),
          _DropdownFilter<String>(
            label: 'Status',
            value: vm.statusPedido,
            items: kDashboardStatusPedidoFiltros
                .map((e) => DropdownMenuItem(value: e.value, child: Text(e.label)))
                .toList(),
            onChanged: vm.setStatusPedido,
          ),
          FilterChip(
            label: const Text('Incluir arquivados'),
            selected: vm.includeDeleted,
            onSelected: vm.setIncludeDeleted,
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
          ),
          FilledButton.icon(
            onPressed: vm.isLoading ? null : onApply,
            icon: vm.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.filter_alt_outlined, size: 18),
            label: Text(vm.isLoading ? 'Carregando...' : 'Aplicar filtros'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    DateTime initial,
    ValueChanged<DateTime> onSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) onSelected(picked);
  }
}

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({
    required this.label,
    required this.date,
    required this.onPick,
  });

  final String label;
  final DateTime date;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final formatted = formatarDataExibicao(date);
    return OutlinedButton.icon(
      onPressed: onPick,
      icon: const Icon(Icons.calendar_today_outlined, size: 16),
      label: Text('$label: $formatted'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: BorderSide(color: AppColors.cardBorder),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}

class _DropdownFilter<T> extends StatelessWidget {
  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: AppColors.input,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide(color: AppColors.inputEnabledBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide(color: AppColors.inputEnabledBorder),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            items: items,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }
}
