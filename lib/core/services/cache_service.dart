import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/history_model.dart';

class CacheService {
  static const String _historyKeyPrefix = "history_";

  // 1. Menyimpan riwayat tontonan
  static Future<void> saveHistory({
    required String dramaId,
    required String episodeId,
    required String platform,
    required String title,
    required int positionMs,
    required int durationMs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = HistoryModel(
      dramaId: dramaId,
      episodeId: episodeId,
      platform: platform,
      title: title,
      positionMs: positionMs,
      durationMs: durationMs,
      lastWatched: DateTime.now().millisecondsSinceEpoch,
    );

    await prefs.setString(
      '$_historyKeyPrefix$dramaId',
      jsonEncode(history.toJson()),
    );
  }

  // 2. Mengambil riwayat tontonan spesifik berdasarkan dramaId
  static Future<HistoryModel?> getHistory(String dramaId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_historyKeyPrefix$dramaId');
    if (jsonStr == null) return null;

    try {
      return HistoryModel.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  // 3. Mengambil semua riwayat tontonan (Memperbaiki error getAllHistory)
  static Future<Map<String, HistoryModel>> getAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, HistoryModel> historyMap = {};

    for (String key in keys) {
      if (key.startsWith(_historyKeyPrefix)) {
        final dramaId = key.replaceFirst(_historyKeyPrefix, "");
        final jsonStr = prefs.getString(key);
        if (jsonStr != null) {
          try {
            historyMap[dramaId] = HistoryModel.fromJson(jsonDecode(jsonStr));
          } catch (_) {}
        }
      }
    }
    return historyMap;
  }

  // 4. Menghapus satu riwayat drama
  static Future<void> deleteHistory(String dramaId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_historyKeyPrefix$dramaId');
  }

  // 5. Menghapus seluruh riwayat tontonan (Memperbaiki error clearAllHistory)
  static Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith(_historyKeyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
