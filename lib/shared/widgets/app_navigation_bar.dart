import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/viewmodels/navigation_controller.dart';

/// Barra de navegação reutilizável com botão Atualizar.
///
/// Implementa [PreferredSizeWidget] para uso como [Scaffold.appBar].
/// Botões desabilitados quando navegação bloqueada ou em loading.
class AppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  /// Título exibido no centro da barra.
  final String? title;

  /// Callback ao pressionar atualizar. Se null, o botão atualizar não é exibido.
  final VoidCallback? onRefresh;

  /// Altura preferida da barra (padrão 56).
  static const double _preferredHeight = 56.0;

  const AppNavigationBar({
    super.key,
    this.title,
    this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(_preferredHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, navController, _) {
        final enabled = navController.buttonsEnabled;

        return AppBar(
          backgroundColor: AppColors.contentBackground,
          elevation: 0,
          leadingWidth: 0,
          leading: const SizedBox.shrink(),
          title: title != null
              ? Text(
                  title!,
                  style: TextStyle(
                    color: AppColors.sidebarTextActive,
                    fontSize: 18,
                  ),
                )
              : null,
          centerTitle: true,
          actions: [
            if (onRefresh != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: enabled ? onRefresh : null,
                color: AppColors.sidebarTextActive,
              ),
          ],
        );
      },
    );
  }
}
