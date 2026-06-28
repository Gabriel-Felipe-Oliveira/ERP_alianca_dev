import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/models/realtime_notification_model.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/viewmodels/notifications_viewmodel.dart';

/// Exibe SnackBar quando chega notificação do erp_realtime.
class RealtimeNotificationListener extends StatefulWidget {
  const RealtimeNotificationListener({super.key, required this.child});

  final Widget child;

  @override
  State<RealtimeNotificationListener> createState() =>
      _RealtimeNotificationListenerState();
}

class _RealtimeNotificationListenerState
    extends State<RealtimeNotificationListener> {
  RealtimeNotificationModel? _lastShown;

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsViewModel>(
      builder: (context, vm, child) {
        final pending = vm.pendingNotification;
        if (pending != null && pending != _lastShown) {
          _lastShown = pending;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showSnackBar(context, vm, pending);
          });
        }
        return child!;
      },
      child: widget.child,
    );
  }

  void _showSnackBar(
    BuildContext context,
    NotificationsViewModel vm,
    RealtimeNotificationModel notification,
  ) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final icon = notification.isAniversario
        ? Icons.cake_outlined
        : Icons.shopping_cart_outlined;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        backgroundColor: AppColors.card,
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification.mensagem,
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        action: _buildAction(context, notification),
      ),
    );
    vm.clearPending();
  }

  SnackBarAction? _buildAction(
    BuildContext context,
    RealtimeNotificationModel notification,
  ) {
    if (notification.isPedidoAbertoLongo) {
      final idPedido = notification.idPedido;
      if (idPedido == null || idPedido <= 0) return null;
      return SnackBarAction(
        label: 'Ver pedido',
        textColor: AppColors.primary,
        onPressed: () => context.push(AppRoutes.pedidosDetalhesId(idPedido)),
      );
    }

    if (notification.isAniversario) {
      final idCliente = notification.idCliente;
      if (idCliente == null || idCliente <= 0) return null;
      return SnackBarAction(
        label: 'Ver cliente',
        textColor: AppColors.primary,
        onPressed: () => context.push(AppRoutes.clientesDetalhesId(idCliente)),
      );
    }

    return null;
  }
}
