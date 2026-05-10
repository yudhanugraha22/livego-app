class HistoryModel {
  final String dramaId;
  final String episodeId;
  final String platform;
  final String title;
  final int positionMs;
  final int durationMs;

  HistoryModel({
    required this.dramaId,
    required this.episodeId,
    required this.platform,
    required this.title,
    required this.positionMs,
    required this.durationMs,
  });
}
