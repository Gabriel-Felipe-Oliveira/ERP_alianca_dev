import 'dart:async';
import 'dart:convert';

import 'package:erp_alianca_dev/core/constants/app_constants.dart';
import 'package:erp_alianca_dev/core/constants/realtime_constants.dart';
import 'package:erp_alianca_dev/core/utils/app_logger.dart';
import 'package:erp_alianca_dev/shared/models/realtime_notification_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Cliente WebSocket Phoenix (erp_realtime). Sem UI — expõe stream de eventos.
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
    if (_connectedEmpresaId == idEmpresa && _channel != null) return;

    await disconnect();

    final uri = Uri.parse(
      '${AppConstants.realtimeWsUrl}?id_empresa=$idEmpresa',
    );

    try {
      _channel = WebSocketChannel.connect(uri);
      _connectedEmpresaId = idEmpresa;
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: true,
      );
      _joinEmpresaChannel(idEmpresa);
      _startHeartbeat();
    } catch (e, st) {
      AppLogger.error(
        'Falha ao conectar WebSocket',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      await disconnect();
    }
  }

  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
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

    final message = jsonEncode([joinRef, ref, topic, event, payload]);
    channel.sink.add(message);
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
        AppLogger.info('Canal fechado: $topic', tag: _tag);
      }
    } catch (e, st) {
      AppLogger.error(
        'Erro ao parsear mensagem WebSocket',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }

  void _emitNotification(Map<String, dynamic> payload) {
    if (_notificationsController.isClosed) return;
    _notificationsController.add(RealtimeNotificationModel.fromPayload(payload));
  }

  void _onError(Object error, [StackTrace? stackTrace]) {
    AppLogger.error(
      'WebSocket erro',
      tag: _tag,
      error: error,
      stackTrace: stackTrace,
    );
    disconnect();
  }

  void _onDone() {
    AppLogger.info('WebSocket encerrado', tag: _tag);
    _channel = null;
    _connectedEmpresaId = null;
  }
}
