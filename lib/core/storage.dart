import 'package:shared_preferences/shared_preferences.dart';
class LiveStorage {
  static Future<void> save(String k, dynamic v) async {
    final p = await SharedPreferences.getInstance();
    if (v is String) p.setString(k, v); else if (v is bool) p.setBool(k, v); else if (v is int) p.setInt(k, v);
  }
  static Future<dynamic> get(String k, dynamic def) async {
    final p = await SharedPreferences.getInstance();
    return p.get(k) ?? def;
  }
  static Future<void> saveHistory(String id, String title, int ep, int sec) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('last_ep_$id', ep);
    await p.setInt('last_sec_${id}_$ep', sec);
    List<String> h = p.getStringList('history_list') ?? [];
    h.removeWhere((item) => item.startsWith(id));
    h.insert(0, "$id|$title|$ep");
    if (h.length > 50) h.removeLast();
    await p.setStringList('history_list', h);
  }
}
