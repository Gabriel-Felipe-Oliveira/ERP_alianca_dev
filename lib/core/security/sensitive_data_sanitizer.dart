/// Remove ou mascara dados sensíveis antes de logar, serializar ou exibir.
abstract final class SensitiveDataSanitizer {
  static const String redacted = '***REDACTED***';

  static const Set<String> _sensitiveKeys = {
    'access_token',
    'refresh_token',
    'authorization',
    'x-access-token',
    'senha',
    'password',
    'token',
    'secret',
    'api_key',
    'apikey',
  };

  static String redact(String? value) {
    if (value == null || value.isEmpty) return redacted;
    if (value.length <= 8) return redacted;
    return '${value.substring(0, 4)}…$redacted';
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll('-', '_');
    return _sensitiveKeys
        .map((k) => k.toLowerCase().replaceAll('-', '_'))
        .contains(normalized);
  }

  static Map<String, dynamic> sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    headers.forEach((key, value) {
      if (_isSensitiveKey(key)) {
        sanitized[key] = _redactHeaderValue(value?.toString());
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  static String _redactHeaderValue(String? value) {
    if (value == null || value.isEmpty) return redacted;
    if (value.toLowerCase().startsWith('bearer ')) {
      return 'Bearer $redacted';
    }
    return redact(value);
  }

  static Object? sanitize(Object? data) {
    if (data == null) return null;
    if (data is Map) return _sanitizeMap(data);
    if (data is List) return data.map(sanitize).toList();
    if (data is String) return _sanitizeStringValue(data);
    return data;
  }

  static Map<String, dynamic> _sanitizeMap(Map<dynamic, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      final keyStr = key.toString();
      if (_isSensitiveKey(keyStr)) {
        result[keyStr] = redact(value?.toString());
      } else if (value is Map) {
        result[keyStr] = _sanitizeMap(value);
      } else if (value is List) {
        result[keyStr] = value.map(sanitize).toList();
      } else {
        result[keyStr] = value;
      }
    });
    return result;
  }

  static String _sanitizeStringValue(String value) {
    if (value.length > 80 && value.contains('.')) {
      // Heurística simples para JWT sem expor o conteúdo.
      return redact(value);
    }
    return value;
  }

  static String sanitizeForLog(Object? data) {
    final sanitized = sanitize(data);
    if (sanitized == null) return '';
    return sanitized.toString();
  }
}
