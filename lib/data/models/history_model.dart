// lib/data/models/history_model.dart

class HistoryModel {
  final String dramaId;
  final String episodeId;
  final String platform;
  final String title;
  final String poster;
  final int episodeNumber;
  final int positionMs;      // Posisi menit/detik terakhir ditonton (milidetik)
  final int durationMs;      // Total durasi video (milidetik)
  final int lastWatched;     // Timestamp waktu menonton (untuk pengurutan)

  HistoryModel({
    required this.dramaId,
    required this.episodeId,
    required this.platform,
    required this.title,
    required this.poster,
    required this.episodeNumber,
    required this.positionMs,
    required this.durationMs,
    required this.lastWatched,
  });

  // Konversi dari data SQLite ke Objek Flutter
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      dramaId: map['drama_id']?.toString() ?? '',
      episodeId: map['episode_id']?.toString() ?? '',
      platform: map['platform']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      poster: map['poster']?.toString() ?? '',
      episodeNumber: map['episode_number'] as int? ?? 0,
      positionMs: map['position_ms'] as int? ?? 0,
      durationMs: map['duration_ms'] as int? ?? 0,
      lastWatched: map['last_watched'] as int? ?? 0,
    );
  }

  // Konversi dari Objek Flutter ke Map SQLite untuk disimpan ke DB
  Map<String, dynamic> toMap() {
    return {
      'drama_id': dramaId,
      'episode_id': episodeId,
      'platform': platform,
      'title': title,
      'poster': poster,
      'episode_number': episodeNumber,
      'position_ms': positionMs,
      'duration_ms': durationMs,
      'last_watched': lastWatched,
    };
  }

  // Menghitung progress persentase menonton (contoh: untuk menampilkan progress bar di bawah poster)
  double get progressPercentage {
    if (durationMs <= 0) return 0.0;
    return positionMs / durationMs;
  }
}
