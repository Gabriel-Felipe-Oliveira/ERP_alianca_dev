import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/features/login/utils/user_perfil.dart';

void main() {
  group('UserPerfil.podeVerDashboardComercial', () {
    test('admin e gerente têm acesso', () {
      expect(UserPerfil.podeVerDashboardComercial('admin'), isTrue);
      expect(UserPerfil.podeVerDashboardComercial('gerente'), isTrue);
      expect(UserPerfil.podeVerDashboardComercial(' Admin '), isTrue);
    });

    test('operador e perfis desconhecidos não têm acesso', () {
      expect(UserPerfil.podeVerDashboardComercial('operador'), isFalse);
      expect(UserPerfil.podeVerDashboardComercial('vendedor'), isFalse);
      expect(UserPerfil.podeVerDashboardComercial(null), isFalse);
      expect(UserPerfil.podeVerDashboardComercial(''), isFalse);
    });
  });
  group('UserPerfil.isAdmin', () {
    test('somente admin', () {
      expect(UserPerfil.isAdmin('admin'), isTrue);
      expect(UserPerfil.isAdmin(' Admin '), isTrue);
      expect(UserPerfil.isAdmin('gerente'), isFalse);
      expect(UserPerfil.isAdmin('operador'), isFalse);
      expect(UserPerfil.isAdmin(null), isFalse);
    });
  });
}
