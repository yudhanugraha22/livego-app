import 'storage_service.dart';
import '../../data/models/history_model.dart';

class CacheService {
  static Future<void> saveHistory({
    required String dramaId,
    required String episodeId,
    required String platform,
    required String title,
    required int positionMs,
    required int durationMs,
  }) async {
    final key = 'history_$dramaId';
    // Format simpan: episodeId|platform|title|positionMs|durationMs
    final data = '$episodeId|$platform|$title|$positionMs|$durationMs';
    await StorageService.write(key, data);
  }

  static Future<HistoryModel?> getHistory(String dramaId) async {
    final key = 'history_$dramaId';
    final rawData = StorageService.read(key);
    if (rawData == null) return null;

    try {
      final parts = rawData.split('|');
      if (parts.length < 5) return null;
      return HistoryModel(
        dramaId: dramaId,
        episodeId: parts[0],
        platform: parts[1],
        title: parts[2],
        positionMs: int.tryParse(parts[3]) ?? 0,
        durationMs: int.tryParse(parts[4]) ?? 0,
      );
    } catch (e) {
      return null;
    }
  }
}
