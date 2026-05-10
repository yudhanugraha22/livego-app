// lib/data/models/episode_model.dart

class EpisodeModel {
  final String id;
  final String title;
  final String? videoUrl;
  final int episodeNumber;

  EpisodeModel({
    required this.id,
    required this.title,
    this.videoUrl,
    required this.episodeNumber,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Episode Baru',
      videoUrl: json['video_url']?.toString(),
      episodeNumber: int.tryParse(json['episode_number']?.toString() ?? '1') ?? 1,
    );
  }
}
