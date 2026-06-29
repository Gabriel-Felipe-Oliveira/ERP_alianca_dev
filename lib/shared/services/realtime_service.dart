import 'dart:async';
import 'dart:convert';

import 'package:erp_alianca_dev/core/constants/app_constants.dart';
import 'package:erp_alianca_dev/core/constants/realtime_constants.dart';
import 'package:erp_alianca_dev/core/utils/app_logger.dart';
import 'package:erp_alianca_dev/shared/models/realtime_notification_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Cliente WebSocket Phoenix (erp_realtime). Falhas são silenciosas — sem UI.
class RealtimeService {
  RealtimeService();

  static const _tag = 'RealtimeService';

  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _subscription;
  Timer? _heartbeatTimer;
  int _ref = 0;
  String? _joinRef;
  int? _connectedEmpresaId;

  final StreamController<RealtimeNotificationModel> _notificationsController =
      StreamController<RealtimeNotificationModel>.broadcast();

  Stream<RealtimeNotificationModel> get notifications =>
      _notificationsController.stream;

  bool get isConnected => _channel != null;

  Future<void> connect({required int idEmpresa}) async {
    if (!AppConstants.realtimeEnabled) return;
    if (_connectedEmpresaId == idEmpresa && _channel != null) return;

    await disconnect();

    final uri = Uri.parse(
      '${AppConstants.realtimeWsUrl}?id_empresa=$idEmpresa',
    );

    try {
      final channel = WebSocketChannel.connect(uri);
      await channel.ready.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('WebSocket timeout'),
      );

      _channel = channel;
      _connectedEmpresaId = idEmpresa;
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
      _joinEmpresaChannel(idEmpresa);
      _startHeartbeat();
    } catch (e, st) {
      AppLogger.debug(
        '[$_tag] Mensageria indisponível (conexão ignorada)',
        tag: _tag,
      );
      AppLogger.debug(e.toString(), tag: _tag);
      if (st != StackTrace.empty) {
        AppLogger.debug(st.toString(), tag: _tag);
      }
      await disconnect();
    }
  }

  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _channel?.sink.close();
    } catch (e) {
      AppLogger.debug('Falha ao fechar canal (já encerrado?): $e',
          tag: 'RealtimeService');
    }
    _channel = null;
    _connectedEmpresaId = null;
    _joinRef = null;
  }

  void dispose() {
    unawaited(disconnect());
    _notificationsController.close();
  }

  void _joinEmpresaChannel(int idEmpresa) {
    final topic = 'empresa:$idEmpresa';
    _joinRef = _nextRef();
    _sendPhoenix(_joinRef!, _joinRef!, topic, 'phx_join', const <String, dynamic>{});
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      final ref = _nextRef();
      _sendPhoenix(ref, ref, 'phoenix', 'heartbeat', const <String, dynamic>{});
    });
  }

  String _nextRef() {
    _ref++;
    return _ref.toString();
  }

  void _sendPhoenix(
    String joinRef,
    String ref,
    String topic,
    String event,
    Map<String, dynamic> payload,
  ) {
    final channel = _channel;
    if (channel == null) return;

    try {
      final message = jsonEncode([joinRef, ref, topic, event, payload]);
      channel.sink.add(message);
    } catch (e) {
      AppLogger.debug('[$_tag] Falha ao enviar frame: $e', tag: _tag);
    }
  }

  void _onMessage(Object? raw) {
    if (raw is! String) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List || decoded.length < 5) return;

      final topic = decoded[2]?.toString() ?? '';
      final event = decoded[3]?.toString() ?? '';
      final payload = decoded[4];

      if (RealtimeConstants.notificationEvents.contains(event)) {
        if (payload is Map<String, dynamic>) {
          _emitNotification(payload);
        } else if (payload is Map) {
          _emitNotification(Map<String, dynamic>.from(payload));
        }
        return;
      }

      if (event == 'phx_close' && topic.startsWith('empresa:')) {
        AppLogger.debug('Canal fechado: $topic', tag: _tag);
      }
    } catch (e) {
      AppLogger.debug('[$_tag] Frame inválido: $e', tag: _tag);
    }
  }

  void _emitNotification(Map<String, dynamic> payload) {
    if (_notificationsController.isClosed) return;
    _notificationsController.add(RealtimeNotificationModel.fromPayload(payload));
  }

  void _onError(Object error, [StackTrace? stackTrace]) {
    AppLogger.debug('[$_tag] Mensageria indisponível: $error', tag: _tag);
    unawaited(disconnect());
  }

  void _onDone() {
    AppLogger.debug('WebSocket encerrado', tag: _tag);
    _channel = null;
    _connectedEmpresaId = null;
  }
}
