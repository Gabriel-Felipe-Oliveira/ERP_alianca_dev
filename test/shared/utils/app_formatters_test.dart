import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';

void main() {
  group('data nascimento API', () {
    test('formatarDataNascimentoApi retorna dd/MM/yyyy', () {
      expect(
        formatarDataNascimentoApi(DateTime(1990, 3, 15)),
        '15/03/1990',
      );
    });

    test('parseDataNascimentoApi converte dd/MM/yyyy', () {
      final parsed = parseDataNascimentoApi('15/03/1990');
      expect(parsed, DateTime(1990, 3, 15));
    });

    test('parseDataNascimentoApi retorna null para valor inválido', () {
      expect(parseDataNascimentoApi(null), isNull);
      expect(parseDataNascimentoApi(''), isNull);
      expect(parseDataNascimentoApi('1990-03-15'), isNull);
      expect(parseDataNascimentoApi('32/13/1990'), isNull);
    });
  });
}
