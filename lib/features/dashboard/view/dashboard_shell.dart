import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/viewmodels/theme_palette_provider.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar_widget.dart';
import 'package:erp_alianca_dev/shared/widgets/app_theme_rebuild_child.dart';
import 'package:erp_alianca_dev/shared/widgets/custom_title_bar.dart';
import 'package:erp_alianca_dev/shared/widgets/realtime_notification_listener.dart';
import 'package:erp_alianca_dev/shared/widgets/reload_progress_overlay.dart';

class DashboardShell extends StatefulWidget {
  final Widget child;

  const DashboardShell({super.key, required this.child});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    context.watch<ThemePaletteProvider>();

    return PopScope(
      canPop: false,
      child: RealtimeNotificationListener(
        child: Scaffold(
          backgroundColor: AppColors.contentBackground,
          body: Column(
            children: [
              const CustomTitleBar(),
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
                          child: AppThemeRebuildChild(child: widget.child),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
