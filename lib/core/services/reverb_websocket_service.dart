import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';
import '../constants/app_endpoints.dart';
import '../network/api_client.dart';

typedef ReverbEventHandler =
    void Function(Map<String, dynamic> payload, String eventName);

class ReverbWebSocketService {
  ReverbWebSocketService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;
  final Map<String, List<ReverbEventHandler>> _handlers = {};
  final Set<String> _subscribedChannels = {};

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _socketSubscription;
  Completer<void>? _connectionCompleter;
  Timer? _reconnectTimer;
  String? _socketId;
  bool _isConnecting = false;
  bool _isDisconnecting = false;

  Future<void> subscribePrivateChannel({
    required String channelName,
    required ReverbEventHandler onEvent,
  }) async {
    final handlers = _handlers.putIfAbsent(channelName, () => []);
    if (!handlers.contains(onEvent)) {
      handlers.add(onEvent);
    }

    await _connectIfNeeded();

    if (!_subscribedChannels.contains(channelName)) {
      await _authorizeAndSubscribe(channelName);
    }
  }

  Future<void> unsubscribe({
    required String channelName,
    ReverbEventHandler? onEvent,
  }) async {
    final handlers = _handlers[channelName];
    if (handlers != null && onEvent != null) {
      handlers.remove(onEvent);
    }

    if (onEvent == null || handlers == null || handlers.isEmpty) {
      _handlers.remove(channelName);
      _subscribedChannels.remove(channelName);
      _send({
        'event': 'pusher:unsubscribe',
        'data': {'channel': channelName},
      });
    }
  }

  Future<void> disconnect() async {
    _isDisconnecting = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _handlers.clear();
    _subscribedChannels.clear();
    _socketId = null;
    _connectionCompleter = null;
    _isConnecting = false;
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    await _channel?.sink.close();
    _channel = null;
    _isDisconnecting = false;
  }

  Future<void> _connectIfNeeded() async {
    if (_socketId != null && _channel != null) {
      return;
    }

    if (_isConnecting && _connectionCompleter != null) {
      return _connectionCompleter!.future;
    }

    _isConnecting = true;
    _isDisconnecting = false;
    _connectionCompleter = Completer<void>();

    try {
      final channel = WebSocketChannel.connect(AppConfig.reverbUri);
      _channel = channel;
      _socketSubscription = channel.stream.listen(
        _handleRawMessage,
        onError: _handleSocketError,
        onDone: _handleSocketDone,
        cancelOnError: false,
      );
      return _connectionCompleter!.future;
    } catch (error, stackTrace) {
      _isConnecting = false;
      _connectionCompleter?.completeError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> _authorizeAndSubscribe(String channelName) async {
    final socketId = _socketId;
    if (socketId == null || socketId.isEmpty) {
      throw StateError('WebSocket belum terhubung.');
    }

    final response = await _apiClient.post(
      AppEndpoints.broadcastingAuth,
      data: {'socket_id': socketId, 'channel_name': channelName},
    );

    final auth = response['auth']?.toString();
    if (auth == null || auth.isEmpty) {
      throw StateError('Auth WebSocket tidak valid.');
    }

    final payload = <String, dynamic>{'channel': channelName, 'auth': auth};

    final channelData = response['channel_data'];
    if (channelData != null) {
      payload['channel_data'] = channelData;
    }

    _send({'event': 'pusher:subscribe', 'data': payload});
  }

  void _handleRawMessage(dynamic rawMessage) {
    final decoded = _decodeObject(rawMessage);
    if (decoded == null) {
      return;
    }

    final eventName = decoded['event']?.toString() ?? '';
    final channelName = decoded['channel']?.toString();

    if (eventName == 'pusher:connection_established') {
      final data = _decodeObject(decoded['data']);
      _socketId = data?['socket_id']?.toString();
      _isConnecting = false;
      if (!(_connectionCompleter?.isCompleted ?? true)) {
        _connectionCompleter?.complete();
      }
      return;
    }

    if (eventName == 'pusher:ping') {
      _send({'event': 'pusher:pong', 'data': <String, dynamic>{}});
      return;
    }

    if (eventName == 'pusher_internal:subscription_succeeded' ||
        eventName == 'pusher:subscription_succeeded') {
      if (channelName != null) {
        _subscribedChannels.add(channelName);
      }
      return;
    }

    if (eventName.startsWith('pusher:') ||
        eventName.startsWith('pusher_internal:')) {
      return;
    }

    if (channelName == null) {
      return;
    }

    final handlers = List<ReverbEventHandler>.of(
      _handlers[channelName] ?? const [],
    );
    if (handlers.isEmpty) {
      return;
    }

    final payload = _decodeObject(decoded['data']) ?? <String, dynamic>{};
    for (final handler in handlers) {
      handler(payload, eventName);
    }
  }

  void _handleSocketError(Object error, StackTrace stackTrace) {
    developer.log(
      'WebSocket error',
      name: 'reverb_websocket',
      error: error,
      stackTrace: stackTrace,
    );
    if (!(_connectionCompleter?.isCompleted ?? true)) {
      _connectionCompleter?.completeError(error, stackTrace);
    }
    _resetConnectionState();
    _scheduleReconnectIfNeeded();
  }

  void _handleSocketDone() {
    _resetConnectionState();
    _scheduleReconnectIfNeeded();
  }

  void _resetConnectionState() {
    _socketId = null;
    _channel = null;
    _socketSubscription = null;
    _isConnecting = false;
    _subscribedChannels.clear();
  }

  void _scheduleReconnectIfNeeded() {
    if (_isDisconnecting || _handlers.isEmpty || _reconnectTimer != null) {
      return;
    }

    _reconnectTimer = Timer(const Duration(seconds: 3), () async {
      _reconnectTimer = null;
      if (_isDisconnecting || _handlers.isEmpty) {
        return;
      }

      try {
        await _connectIfNeeded();
        for (final channelName in List<String>.of(_handlers.keys)) {
          await _authorizeAndSubscribe(channelName);
        }
      } catch (error, stackTrace) {
        developer.log(
          'WebSocket reconnect failed',
          name: 'reverb_websocket',
          error: error,
          stackTrace: stackTrace,
        );
        _scheduleReconnectIfNeeded();
      }
    });
  }

  void _send(Map<String, dynamic> payload) {
    final channel = _channel;
    if (channel == null) {
      return;
    }

    channel.sink.add(jsonEncode(payload));
  }

  Map<String, dynamic>? _decodeObject(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } on FormatException {
        return null;
      }
    }

    return null;
  }
}
