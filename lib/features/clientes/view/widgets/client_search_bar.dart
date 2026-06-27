import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/clientes_viewmodel.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Campo de busca fixo no topo do painel principal.
class ClientSearchBar extends StatelessWidget {
  const ClientSearchBar({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientesViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.listagemSearchBarBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              onChanged: (value) => vm.query = value,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar clientes por nome...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: vm.query.trim().isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 18,
                          color: AppColors.error,
                        ),
                        onPressed: () {
                          controller.clear();
                          vm.resetBusca();
                        },
                        style: IconButton.styleFrom(
                          foregroundColor: AppColors.error,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                filled: true,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
