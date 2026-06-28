import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar_widget.dart';
import 'package:erp_alianca_dev/shared/utils/app_restart_controller.dart';
import 'package:erp_alianca_dev/shared/widgets/custom_title_bar.dart';
import 'package:erp_alianca_dev/shared/widgets/realtime_notification_listener.dart';
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
    return PopScope(
      canPop: false,
      child: RealtimeNotificationListener(
        child: Scaffold(
          backgroundColor: AppColors.contentBackground,
          body: Column(
            children: [
              CustomTitleBar(
                onRefresh: () =>
                    context.read<AppRestartController>().restartApp(),
                onRestart: () =>
                    context.read<AppRestartController>().restartApp(),
              ),
              Expanded(
                child: Row(
                  children: [
                    const SidebarWidget(),
                    Expanded(
                      child: ReloadProgressOverlay(
                        child: Container(
                          color: AppColors.contentBackground,
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _controller,
                              curve: SidebarConstants.expandAnimationCurve,
                            ),
                            child: widget.child,
                          ),
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
