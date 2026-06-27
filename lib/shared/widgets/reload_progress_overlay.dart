import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/viewmodels/navigation_controller.dart';

/// Altura da barra de progresso de recarregar.
const double kReloadProgressBarHeight = 4.0;

/// Duração da animação de fade do conteúdo ao recarregar.
const Duration kReloadFadeDuration = Duration(milliseconds: 200);

/// Envolve o conteúdo da tela e exibe animação de recarregar:
/// quando [NavigationController.isLoading] é true, o conteúdo some e
/// uma barra de progresso azul aparece no topo.
///
/// Usado no [DashboardShell] para que todas as telas tenham o mesmo
/// comportamento ao clicar em Atualizar.
class ReloadProgressOverlay extends StatelessWidget {
  /// Conteúdo da tela (sidebar não entra aqui; apenas a área de conteúdo).
  final Widget child;

  const ReloadProgressOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, navController, _) {
        final isLoading = navController.isLoading;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Conteúdo: some quando está carregando
            AnimatedOpacity(
              duration: kReloadFadeDuration,
              opacity: isLoading ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: isLoading,
                child: child,
              ),
            ),

            // Barra de progresso azul no topo — Positioned precisa ser filho direto do Stack
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: kReloadFadeDuration,
                opacity: isLoading ? 1.0 : 0.0,
                child: const IgnorePointer(
                  ignoring: true,
                  child: _ReloadProgressBar(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Barra de progresso azul indeterminada no topo da área de conteúdo.
class _ReloadProgressBar extends StatelessWidget {
  const _ReloadProgressBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kReloadProgressBarHeight,
      child: LinearProgressIndicator(
        backgroundColor: AppColors.contentBackground,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}
