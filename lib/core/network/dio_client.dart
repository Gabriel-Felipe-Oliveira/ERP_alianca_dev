import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:erp_alianca_dev/core/constants/app_constants.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/network/sanitized_dio_logger.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';

class DioClient {
  DioClient(
    this._empresaService,
    this._authService, {
    Dio? dio,
  }) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: AppConstants.connectionTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authService.isAuthenticated) {
            final token = _authService.accessToken;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            final params = Map<String, dynamic>.from(
              options.queryParameters.isEmpty ? {} : options.queryParameters,
            );
            params['id_empresa'] = _empresaService.idEmpresa;
            options.queryParameters = params;
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              _authService.isAuthenticated) {
            final refreshed = await _authService.tryRefreshAccessToken();
            if (refreshed) {
              final token = _authService.accessToken;
              final request = error.requestOptions;
              request.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch<Object?>(request);
                return handler.resolve(response);
              } catch (retryError) {
                if (retryError is DioException) {
                  return handler.next(retryError);
                }
              }
            }
            await _authService.logoutLocal();
          }

          return handler.next(error);
        },
      ),
    );

    if (dio == null && kDebugMode) {
      _dio.interceptors.add(SanitizedDioLogger());
    }
  }

  late final Dio _dio;
  final EmpresaService _empresaService;
  final AuthService _authService;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
