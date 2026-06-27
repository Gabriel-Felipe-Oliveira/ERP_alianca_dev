import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/security/sensitive_data_sanitizer.dart';

void main() {
  group('SensitiveDataSanitizer', () {
    test('redact mascara valor longo', () {
      const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload';
      final redacted = SensitiveDataSanitizer.redact(token);
      expect(redacted, isNot(equals(token)));
      expect(redacted, contains(SensitiveDataSanitizer.redacted));
    });

    test('sanitize remove tokens de mapa aninhado', () {
      final sanitized = SensitiveDataSanitizer.sanitize({
        'ok': true,
        'access_token': 'secret-access',
        'refresh_token': 'secret-refresh',
        'usuario': {
          'email': 'a@b.com',
          'senha': 'nao-expor',
        },
      }) as Map<String, dynamic>;

      expect(sanitized['access_token'], isNot('secret-access'));
      expect(sanitized['refresh_token'], isNot('secret-refresh'));
      expect(
        (sanitized['usuario'] as Map)['senha'],
        isNot('nao-expor'),
      );
      expect(sanitized['usuario']['email'], 'a@b.com');
    });

    test('sanitizeHeaders mascara Authorization Bearer', () {
      final headers = SensitiveDataSanitizer.sanitizeHeaders({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.token',
        'X-Access-Token': 'raw-token-value',
      });

      expect(headers['Content-Type'], 'application/json');
      expect(headers['Authorization'], 'Bearer ***REDACTED***');
      expect(headers['X-Access-Token'], isNot('raw-token-value'));
    });

    test('sanitizeForLog não contém segredos originais', () {
      const secret = 'super-secret-refresh-token-value';
      final log = SensitiveDataSanitizer.sanitizeForLog({
        'refresh_token': secret,
      });
      expect(log, isNot(contains(secret)));
    });
  });
}
