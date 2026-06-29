import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/models/app_feedback.dart';
import 'package:erp_alianca_dev/shared/models/realtime_notification_model.dart';
import 'package:erp_alianca_dev/shared/viewmodels/notifications_viewmodel.dart';
import 'package:erp_alianca_dev/shared/widgets/app_toast.dart';

/// Exibe feedback padronizado quando chega notificação do erp_realtime.
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
            _showFeedback(context, vm, pending);
          });
        }
        return child!;
      },
      child: widget.child,
    );
  }

  void _showFeedback(
    BuildContext context,
    NotificationsViewModel vm,
    RealtimeNotificationModel notification,
  ) {
    final action = _buildAction(context, notification);
    showAppFeedback(
      context,
      feedback: AppFeedbackMessage.info(
        notification.mensagem,
        title: notification.isAniversario ? 'Aniversário' : 'Notificação',
        duration: const Duration(seconds: 8),
        actionLabel: action?.label,
        onAction: action?.onPressed,
      ),
    );
    vm.clearPending();
  }

  ({String label, VoidCallback onPressed})? _buildAction(
    BuildContext context,
    RealtimeNotificationModel notification,
  ) {
    if (notification.isPedidoAbertoLongo) {
      final idPedido = notification.idPedido;
      if (idPedido == null || idPedido <= 0) return null;
      return (
        label: 'Ver pedido',
        onPressed: () => context.push(AppRoutes.pedidosDetalhesId(idPedido)),
      );
    }

    if (notification.isAniversario) {
      final idCliente = notification.idCliente;
      if (idCliente == null || idCliente <= 0) return null;
      return (
        label: 'Ver cliente',
        onPressed: () => context.push(AppRoutes.clientesDetalhesId(idCliente)),
      );
    }

    return null;
  }
}
