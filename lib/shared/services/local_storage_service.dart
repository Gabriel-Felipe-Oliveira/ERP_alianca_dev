import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  // Bool
  Future<bool> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  // Int
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  int? getInt(String key) => _prefs.getInt(key);

  // Remove
  Future<bool> remove(String key) => _prefs.remove(key);

  // Clear all
  Future<bool> clear() => _prefs.clear();

  static const String idEmpresaKey = 'id_empresa';
  static const String themeLightModeKey = 'theme_light_mode';

  Future<bool> saveIdEmpresa(int id) => setInt(idEmpresaKey, id);

  int? getIdEmpresa() => getInt(idEmpresaKey);

  Future<bool> clearIdEmpresa() => remove(idEmpresaKey);
}
