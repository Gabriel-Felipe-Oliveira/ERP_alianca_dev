import 'package:dio/dio.dart';
import 'package:erp_alianca_dev/core/constants/app_constants.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/shared/models/cnpj_consulta_model.dart';

/// Consulta CNPJ na Brasil API (dados públicos da Receita Federal).
class CnpjConsultaService {
  CnpjConsultaService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.brasilApiCnpjBaseUrl,
                connectTimeout: AppConstants.connectionTimeout,
                receiveTimeout: AppConstants.receiveTimeout,
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;

  Future<CnpjConsultaModel> consultar(String cnpj) async {
    final digits = cnpj.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) {
      throw const AppException(message: 'Informe um CNPJ válido com 14 dígitos.');
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>('/$digits');
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const AppException(message: 'Nenhum dado encontrado para este CNPJ.');
      }
      return CnpjConsultaModel.fromBrasilApiJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const AppException(
          message: 'CNPJ não encontrado na base da Receita Federal.',
        );
      }
      throw AppException.fromDioException(e);
    }
  }
}
