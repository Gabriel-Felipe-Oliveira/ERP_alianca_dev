import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/viewmodels/navigation_controller.dart';
import 'package:window_manager/window_manager.dart';

/// Barra de título customizada que substitui a nativa do Windows.
/// À esquerda: botão Atualizar (respeita [NavigationController]).
/// À direita: botões de janela (minimizar, maximizar, fechar).
class CustomTitleBar extends StatelessWidget {
  static const double height = 32;

  /// Callback ao pressionar Atualizar. Se null, o botão ainda aparece mas não faz nada.
  final VoidCallback? onRefresh;

  /// Callback ao segurar Atualizar por 3s (reinício completo do app).
  final VoidCallback? onRestart;

  const CustomTitleBar({super.key, this.onRefresh, this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, navController, _) {
        final buttonsEnabled = navController.buttonsEnabled;

        return Container(
          height: height,
          color: AppColors.sidebarBackground,
          child: Row(
            children: [
              // Botão Atualizar (tap = recarregar tela; segurar 3s = reiniciar app)
              _NavButton(
                icon: Icons.refresh,
                onPressed: buttonsEnabled ? (onRefresh ?? () {}) : null,
                onLongPressAfterDelay: buttonsEnabled ? onRestart : null,
                longPressDuration: const Duration(seconds: 3),
              ),
              // Divisor sutil entre navegação e área arrastável
              Container(
                width: 1,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: AppColors.sidebarDivider,
              ),
              // Área arrastável (move a janela)
              Expanded(
                child: GestureDetector(
                  onDoubleTap: _toggleMaximize,
                  child: const DragToMoveArea(
                    child: SizedBox.expand(),
                  ),
                ),
              ),
              // Botões de controle da janela
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
      },
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

/// Botão de navegação na barra superior (Voltar / Atualizar).
/// Suporta long-press: após [longPressDuration] chama [onLongPressAfterDelay].
class _NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressAfterDelay;
  final Duration longPressDuration;

  const _NavButton({
    required this.icon,
    this.onPressed,
    this.onLongPressAfterDelay,
    this.longPressDuration = const Duration(seconds: 3),
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;
  Timer? _longPressTimer;

  void _onTapDown(TapDownDetails _) {
    if (widget.onLongPressAfterDelay == null) return;
    _longPressTimer?.cancel();
    _longPressTimer = Timer(widget.longPressDuration, () {
      _longPressTimer = null;
      widget.onLongPressAfterDelay?.call();
    });
  }

  void _onTapUp(TapUpDetails _) => _longPressTimer?.cancel();
  void _onTapCancel() => _longPressTimer?.cancel();

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          _longPressTimer?.cancel();
          widget.onPressed?.call();
        },
        child: Container(
          width: 40,
          height: CustomTitleBar.height,
          color: _isHovered && enabled
              ? AppColors.sidebarDivider
              : Colors.transparent,
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: 18,
            color: enabled
                ? AppColors.sidebarTextActive
                : AppColors.sidebarTextMuted,
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
              ? (widget.isClose ? const Color(0xFFE81123) : AppColors.sidebarDivider)
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
