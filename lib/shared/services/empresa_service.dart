import 'package:flutter/foundation.dart';
import 'package:erp_alianca_dev/shared/models/empresa_model.dart';
import 'package:erp_alianca_dev/shared/services/local_storage_service.dart';

/// Id da empresa mock usada **apenas** antes do login (paleta/tema inicial).
/// Após autenticação, [setEmpresa] substitui pelo tenant da sessão.
const int kDefaultIdEmpresa = 3;

/// Serviço que mantém a empresa atual da sessão.
class EmpresaService extends ChangeNotifier {
  EmpresaService() : _current = _empresaMock;

  static final EmpresaModel _empresaMock = EmpresaModel(
    idEmpresa: kDefaultIdEmpresa,
    razaoSocial: 'Alianca Tech',
    nomeFantasia: 'Tech',
    cnpj: '000000000',
    email: 'itallodev21@gmail.com',
    telefone: '21999999999',
    cep: '32606470',
    logradouro: 'rua hermano lott junior 37',
    numero: '37',
    bairro: 'bom retiro',
    cidade: 'betim',
    estado: 'mg',
    status: 'ativa',
    deletedAt: null,
    createdAt: '2026-02-13 21:12:54',
    updatedAt: '2026-02-13 21:12:54',
  );

  EmpresaModel _current;

  /// Id da empresa atual. Usado pelo Dio para enviar em todas as rotas.
  int get idEmpresa => _current.idEmpresa;

  /// Empresa atual (para exibição na UI, se necessário).
  EmpresaModel get current => _current;

  /// Restaura id_empresa persistido após login.
  Future<void> restoreFromStorage(LocalStorageService storage) async {
    final id = storage.getIdEmpresa();
    if (id == null || id == _current.idEmpresa) return;
    _current = EmpresaModel(
      idEmpresa: id,
      razaoSocial: _current.razaoSocial,
      nomeFantasia: _current.nomeFantasia,
      cnpj: _current.cnpj,
      email: _current.email,
      telefone: _current.telefone,
      cep: _current.cep,
      logradouro: _current.logradouro,
      numero: _current.numero,
      bairro: _current.bairro,
      cidade: _current.cidade,
      estado: _current.estado,
      status: _current.status,
      deletedAt: _current.deletedAt,
      createdAt: _current.createdAt,
      updatedAt: _current.updatedAt,
    );
    notifyListeners();
  }

  /// Define empresa da sessão e persiste id.
  Future<void> setEmpresa(EmpresaModel empresa, LocalStorageService storage) async {
    _current = empresa;
    await storage.saveIdEmpresa(empresa.idEmpresa);
    notifyListeners();
  }

  /// Persiste apenas id_empresa quando a API não retorna objeto empresa.
  Future<void> setEmpresaId(int id, LocalStorageService storage) async {
    if (id == _current.idEmpresa) {
      await storage.saveIdEmpresa(id);
      return;
    }
    _current = EmpresaModel(
      idEmpresa: id,
      razaoSocial: _current.razaoSocial,
      nomeFantasia: _current.nomeFantasia,
      cnpj: _current.cnpj,
      email: _current.email,
      telefone: _current.telefone,
      cep: _current.cep,
      logradouro: _current.logradouro,
      numero: _current.numero,
      bairro: _current.bairro,
      cidade: _current.cidade,
      estado: _current.estado,
      status: _current.status,
      deletedAt: _current.deletedAt,
      createdAt: _current.createdAt,
      updatedAt: _current.updatedAt,
    );
    await storage.saveIdEmpresa(id);
    notifyListeners();
  }

  /// Volta ao mock padrão (logout).
  Future<void> clearSession(LocalStorageService storage) async {
    _current = _empresaMock;
    await storage.clearIdEmpresa();
    notifyListeners();
  }
}
