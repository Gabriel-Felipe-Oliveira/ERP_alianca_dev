import 'package:erp_alianca_dev/core/config/api_config.dart';
import 'package:erp_alianca_dev/core/constants/pagination_constants.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';

/// Envelope normalizado da API ({ ok/success, message, data }).
class ApiResponse<T> {
  const ApiResponse({
    required this.ok,
    this.message,
    this.data,
  });

  final bool ok;
  final String? message;
  final T? data;
}

/// Parsing defensivo de respostas heterogêneas da API (ok, success, data, lista direta).
class ApiResponseParser {
  ApiResponseParser._();

  static bool isSuccess(Object? raw) {
    if (raw == null) return false;
    final map = asMap(raw);
    if (map == null) return true;
    return map['ok'] == true || map['success'] == true;
  }

  static String? message(Object? raw) {
    final map = asMap(raw);
    if (map == null) return null;
    final msg = map['message'];
    if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    final err = map['error'];
    if (err is String && err.trim().isNotEmpty) return err.trim();
    return null;
  }

  static Map<String, dynamic>? asMap(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  /// Extrai lista de mapas JSON a partir de lista direta ou envelope { data: [...] }.
  static List<Map<String, dynamic>> extractMaps(
    Object? raw, {
    String? nestedKey,
  }) {
    if (raw == null) return [];

    List<Object?> items;
    if (raw is List) {
      items = raw;
    } else {
      final map = asMap(raw);
      if (map == null) return [];
      final data = map['data'];
      if (data is List) {
        items = data;
      } else if (data is Map) {
        items = [data];
      } else {
        items = [map];
      }
    }

    return items.map(asMap).whereType<Map<String, dynamic>>().map((map) {
      if (nestedKey == null) return map;
      final inner = map[nestedKey];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return map;
    }).toList();
  }

  static List<T> parseList<T>(
    Object? raw,
    T Function(Map<String, dynamic> json) fromJson, {
    String? nestedKey,
  }) {
    return extractMaps(raw, nestedKey: nestedKey).map(fromJson).toList();
  }

  static int? _asInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  /// Parseia lista paginada com metadados (total/page) ou fallback client-side.
  static PaginatedResult<T> parsePaginatedList<T>(
    Object? raw,
    T Function(Map<String, dynamic> json) fromJson, {
    required int requestedPage,
    int requestedLimit = PaginationConstants.defaultLimit,
    String? nestedKey,
  }) {
    final allItems = parseList(raw, fromJson, nestedKey: nestedKey);
    final map = asMap(raw);

    int? total;
    int? pageMeta;
    int? limitMeta;

    if (map != null) {
      total = _asInt(map['total']);
      pageMeta = _asInt(map['page']);
      limitMeta = _asInt(map['limit']);
      final data = map['data'];
      if (data is Map) {
        total ??= _asInt(data['total']);
        pageMeta ??= _asInt(data['page']);
        limitMeta ??= _asInt(data['limit']);
      }
    }

    if (total != null) {
      final page = pageMeta ?? requestedPage;
      final limit = limitMeta ?? requestedLimit;
      return PaginatedResult<T>(
        items: allItems,
        page: page,
        limit: limit,
        total: total,
        hasMore: page * limit < total,
        serverPaginated: true,
      );
    }

    if (allItems.length > requestedLimit) {
      final start = (requestedPage - 1) * requestedLimit;
      final slice = allItems.skip(start).take(requestedLimit).toList();
      return PaginatedResult<T>(
        items: slice,
        page: requestedPage,
        limit: requestedLimit,
        total: allItems.length,
        hasMore: start + slice.length < allItems.length,
        fullCache: allItems,
      );
    }

    return PaginatedResult<T>(
      items: allItems,
      page: 1,
      limit: allItems.isEmpty ? requestedLimit : allItems.length,
      total: allItems.length,
      hasMore: false,
    );
  }

  /// Parseia um único objeto (envelope, lista com um item ou objeto na raiz).
  static T? parseObject<T>(
    Object? raw,
    T Function(Map<String, dynamic> json) fromJson, {
    List<String> rootEntityKeys = const [],
  }) {
    if (raw == null) return null;

    if (raw is List) {
      if (raw.isEmpty) return null;
      final map = asMap(raw.first);
      return map != null ? fromJson(map) : null;
    }

    final map = asMap(raw);
    if (map == null) return null;

    final data = map['data'];
    if (data is Map) {
      return fromJson(Map<String, dynamic>.from(data));
    }
    if (data is List) {
      if (data.isEmpty) return null;
      final first = asMap(data.first);
      return first != null ? fromJson(first) : null;
    }

    if (rootEntityKeys.isNotEmpty &&
        !rootEntityKeys.any(map.containsKey)) {
      return null;
    }

    return fromJson(map);
  }

  static T parseRequiredObject<T>(
    Object? raw,
    T Function(Map<String, dynamic> json) fromJson, {
    List<String> rootEntityKeys = const [],
    String notFoundMessage = 'Registro não encontrado.',
  }) {
    final result = parseObject(
      raw,
      fromJson,
      rootEntityKeys: rootEntityKeys,
    );
    if (result == null) {
      throw Exception(notFoundMessage);
    }
    return result;
  }

  /// Valida resposta de mutação (POST/PUT/PATCH/DELETE) com ok/success.
  static void requireOk(
    Map<String, dynamic>? data, {
    required String defaultMessage,
    bool allowEmptyResponseOnSuccess = false,
    int? statusCode,
  }) {
    if (data == null) {
      if (allowEmptyResponseOnSuccess &&
          statusCode != null &&
          ApiConfig.isSuccessStatusCode(statusCode)) {
        return;
      }
      throw Exception('Resposta inválida da API');
    }
    if (!isSuccess(data)) {
      throw Exception(message(data) ?? defaultMessage);
    }
  }
}
