import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/viewmodels/theme_palette_provider.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar_widget.dart';
import 'package:erp_alianca_dev/shared/widgets/app_theme_rebuild_child.dart';
import 'package:erp_alianca_dev/shared/widgets/custom_title_bar.dart';
import 'package:erp_alianca_dev/shared/widgets/reload_progress_overlay.dart';
class DashboardShell extends StatefulWidget {
  final Widget child;

  const DashboardShell({super.key, required this.child});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _sidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SidebarConstants.expandAnimationDuration,
    )..value = 1.0;
  }

  @override
  void didUpdateWidget(covariant DashboardShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child.runtimeType != oldWidget.child.runtimeType) {
      _controller.value = 0.0;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemePaletteProvider>();

    return PopScope(      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.contentBackground,
        body: Column(
        children: [
          // Barra de título: reinício total (anti-bug), independente do estado do app
          const CustomTitleBar(),

          // Conteúdo principal (sidebar + área de conteúdo)
          Expanded(
            child: Row(
              children: [
                SidebarWidget(
                  isCollapsed: _sidebarCollapsed,
                  onToggleCollapsed: () {
                    setState(() => _sidebarCollapsed = !_sidebarCollapsed);
                  },
                ),
                Expanded(
                  child: ReloadProgressOverlay(
                    child: Container(
                      color: AppColors.contentBackground,
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _controller,
                          curve: SidebarConstants.expandAnimationCurve,
                        ),
                        child: AppThemeRebuildChild(child: widget.child),
                      ),
                    ),
                  ),
                ),              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
