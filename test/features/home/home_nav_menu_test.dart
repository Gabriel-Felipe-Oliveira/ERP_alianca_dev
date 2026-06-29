import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/features/home/view/widgets/home_nav_menu.dart';
import 'package:erp_alianca_dev/features/login/model/auth_session_model.dart';
import 'package:erp_alianca_dev/features/login/model/usuario_model.dart';
import 'package:erp_alianca_dev/shared/models/empresa_model.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/services/auth_storage_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/local_storage_service.dart';

void main() {
  AuthService authWithPerfil(String perfil) {
    final empresaService = EmpresaService();
    final auth = AuthService(
      authStorage: AuthStorageService(LocalStorageService()),
      empresaService: empresaService,
      localStorageService: LocalStorageService(),
    );
    auth.debugSetSession(
      AuthSessionModel(
        accessToken: 't',
        refreshToken: 'r',
        accessExpiresAt: DateTime.now().add(const Duration(hours: 1)),
        idSession: 1,
        deviceName: 'test',
        empresa: EmpresaModel(
          idEmpresa: 1,
          razaoSocial: 'Teste',
          nomeFantasia: 'Teste',
          cnpj: '',
          email: '',
          telefone: '',
          cep: '',
          logradouro: '',
          numero: '',
          bairro: '',
          cidade: '',
          estado: '',
          status: 'ativa',
        ),
        usuario: UsuarioModel(
          idUsuario: 1,
          idEmpresa: 1,
          nome: 'User',
          email: 'u@test.com',
          telefone: '',
          perfil: perfil,
          status: 'ativo',
        ),
      ),
    );
    return auth;
  }

  bool temSecaoDashboard(AuthService auth) {
    return HomeNavMenu.sectionsFor(auth).any((s) => s.title == 'Dashboard');
  }

  test('admin vê card Dashboard na Home', () {
    expect(temSecaoDashboard(authWithPerfil('admin')), isTrue);
  });

  test('gerente vê card Dashboard na Home', () {
    expect(temSecaoDashboard(authWithPerfil('gerente')), isTrue);
  });

  test('operador não vê card Dashboard na Home', () {
    expect(temSecaoDashboard(authWithPerfil('operador')), isFalse);
  });
}
