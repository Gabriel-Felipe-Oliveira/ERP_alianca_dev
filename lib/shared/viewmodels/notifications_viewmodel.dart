import 'dart:async';

import 'package:erp_alianca_dev/shared/models/realtime_notification_model.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/realtime_service.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';

/// Escuta o WebSocket e filtra notificações relevantes ao usuário logado.
class NotificationsViewModel extends BaseViewModel {
  NotificationsViewModel(
    this._realtimeService,
    this._authService,
    this._empresaService,
  ) {
    _authService.addListener(_syncConnection);
    _empresaService.addListener(_syncConnection);
    _subscription = _realtimeService.notifications.listen(_onNotification);
    _syncConnection();
  }

  final RealtimeService _realtimeService;
  final AuthService _authService;
  final EmpresaService _empresaService;

  StreamSubscription<RealtimeNotificationModel>? _subscription;
  RealtimeNotificationModel? _pending;

  RealtimeNotificationModel? get pendingNotification => _pending;

  void clearPending() {
    _pending = null;
    notifyListeners();
  }

  void _syncConnection() {
    if (isDisposed) return;

    if (!_authService.isAuthenticated) {
      _realtimeService.disconnect();
      return;
    }

    final idEmpresa = _empresaService.idEmpresa;
    if (idEmpresa <= 0) return;

    unawaited(_connect(idEmpresa));
  }

  Future<void> _connect(int idEmpresa) async {
    await _realtimeService.connect(idEmpresa: idEmpresa);
    if (isDisposed) return;
  }

  void _onNotification(RealtimeNotificationModel notification) {
    if (isDisposed) return;

    final idUsuario = _authService.usuario?.idUsuario;
    if (!notification.isDestinadaAoUsuario(idUsuario)) return;

    _pending = notification;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.removeListener(_syncConnection);
    _empresaService.removeListener(_syncConnection);
    _subscription?.cancel();
    super.dispose();
  }
}
