import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Toast centralizado em card, padrão do app (cor da sidebar, boa legibilidade).
/// Exibe [message] no centro da tela por [duration] e some com fade.
void showAppToast(
  BuildContext context, {
  required String message,
  bool isError = false,
  Duration duration = const Duration(seconds: 2),
  OverlayState? overlay,
  ScaffoldMessengerState? messenger,
}) {
  final overlay0 = overlay ?? Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (ctx) => _AppToastOverlay(
      message: message,
      isError: isError,
    ),
  );

  overlay0.insert(entry);
  Future.delayed(duration, () {
    if (entry.mounted) entry.remove();
  });
}

class _AppToastOverlay extends StatefulWidget {
  final String message;
  final bool isError;

  const _AppToastOverlay({
    required this.message,
    required this.isError,
  });

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.sidebarBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.sidebarBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isError)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 24,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: AppColors.sidebarTextActive,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
