import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/features/home/utils/home_welcome_messages.dart';

void main() {
  group('HomeWelcomeMessages', () {
    test('greeting usa o primeiro nome', () {
      expect(
        HomeWelcomeMessages.greeting('Gabriel Silva'),
        'Olá, Gabriel!',
      );
    });

    test('greeting sem nome usa fallback', () {
      expect(HomeWelcomeMessages.greeting(null), 'Olá, usuário!');
      expect(HomeWelcomeMessages.greeting(''), 'Olá, usuário!');
    });
  });
}
