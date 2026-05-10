class HistoryModel {
  final String dramaId;
  final String episodeId;
  final String platform;
  final String title;
  final int positionMs;
  final int durationMs;
  final int lastWatched;

  HistoryModel({
    required this.dramaId,
    required this.episodeId,
    required this.platform,
    required this.title,
    required this.positionMs,
    required this.durationMs,
    required this.lastWatched,
  });

  // Factory untuk konversi dari JSON ke Objek
  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      dramaId: json['dramaId'] ?? json['drama_id'] ?? '',
      episodeId: json['episodeId'] ?? json['episode'] ?? '',
      platform: json['platform'] ?? '',
      title: json['title'] ?? '',
      positionMs: json['positionMs'] ?? json['position'] ?? 0,
      durationMs: json['durationMs'] ?? json['duration'] ?? 0,
      lastWatched: json['lastWatched'] ?? json['last_watched'] ?? 0,
    );
  }

  // Konversi dari Objek ke JSON Map
  Map<String, dynamic> toJson() {
    return {
      'dramaId': dramaId,
      'episodeId': episodeId,
      'platform': platform,
      'title': title,
      'positionMs': positionMs,
      'durationMs': durationMs,
      'lastWatched': lastWatched,
    };
  }
}
