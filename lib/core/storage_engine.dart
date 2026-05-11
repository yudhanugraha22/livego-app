import 'package:shared_preferences/shared_preferences.dart';
class StorageEngine {
  static Future<void> save(String k, dynamic v) async {
    final p = await SharedPreferences.getInstance();
    if (v is String) p.setString(k, v); else if (v is bool) p.setBool(k, v); else if (v is int) p.setInt(k, v);
  }
  static Future<dynamic> read(String k, dynamic def) async {
    final p = await SharedPreferences.getInstance();
    return p.get(k) ?? def;
  }
}
