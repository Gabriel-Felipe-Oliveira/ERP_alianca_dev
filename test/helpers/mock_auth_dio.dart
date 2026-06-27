import 'package:dio/dio.dart';

/// Dio mock que roteia respostas por path + método HTTP.
Dio createRoutedMockDio(
  Object? Function(RequestOptions options) router, {
  int defaultStatusCode = 200,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local/'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final data = router(options);
        handler.resolve(
          Response<Object?>(
            requestOptions: options,
            data: data,
            statusCode: defaultStatusCode,
          ),
        );
      },
    ),
  );
  return dio;
}

/// Dio mock que responde com erro HTTP.
Dio createFailingMockDio({
  required int statusCode,
  Object? responseData,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local/'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response<Object?>(
              requestOptions: options,
              data: responseData,
              statusCode: statusCode,
            ),
            type: DioExceptionType.badResponse,
          ),
        );
      },
    ),
  );
  return dio;
}
