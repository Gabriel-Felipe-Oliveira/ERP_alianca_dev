import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tooltip.dart';
import 'package:erp_alianca_dev/shared/viewmodels/theme_palette_provider.dart';
import 'package:erp_alianca_dev/shared/utils/app_hard_restart.dart';
import 'package:window_manager/window_manager.dart';

/// Barra de título customizada que substitui a nativa do Windows.
/// À esquerda: botão **Reiniciar** (anti-bug, sempre ativo).
/// À direita: botões de janela (minimizar, maximizar, fechar).
class CustomTitleBar extends StatelessWidget {
  static const double height = 32;

  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemePaletteProvider>();

    return Container(
      height: height,
      color: AppColors.sidebarBackground,
      child: Row(
        children: [
          _HardRestartButton(
            onPressed: () => unawaited(AppHardRestart.restart()),
          ),
          Expanded(
            child: GestureDetector(
              onDoubleTap: _toggleMaximize,
              child: const DragToMoveArea(
                child: SizedBox.expand(),
              ),
            ),
          ),
          _WindowButton(
            icon: Icons.minimize,
            onPressed: () => windowManager.minimize(),
          ),
          _WindowButton(
            icon: Icons.crop_square,
            onPressed: _toggleMaximize,
          ),
          _WindowButton(
            icon: Icons.close,
            onPressed: () => windowManager.close(),
            isClose: true,
          ),
        ],
      ),
    );
  }

  static Future<void> _toggleMaximize() async {
    final isMaximized = await windowManager.isMaximized();
    if (isMaximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }
}

/// Reinício total do app — **sempre habilitado**, sem depender do estado da UI.
class _HardRestartButton extends StatefulWidget {
  const _HardRestartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_HardRestartButton> createState() => _HardRestartButtonState();
}

class _HardRestartButtonState extends State<_HardRestartButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AppTooltip(
        message: 'Reiniciar aplicativo (limpa tudo)',
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 40,
            height: CustomTitleBar.height,
            color: _isHovered
                ? AppColors.sidebarDivider
                : Colors.transparent,
            alignment: Alignment.center,
            child: Icon(
              Icons.refresh,
              size: 18,
              color: AppColors.sidebarTextActive,
            ),
          ),
        ),
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: CustomTitleBar.height,
          color: _isHovered
              ? (widget.isClose
                  ? const Color(0xFFE81123)
                  : AppColors.sidebarDivider)
              : Colors.transparent,
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: 16,
            color: _isHovered && widget.isClose
                ? Colors.white
                : AppColors.sidebarTextMuted,
          ),
        ),
      ),
    );
  }
}
