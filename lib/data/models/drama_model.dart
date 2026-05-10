// lib/data/models/drama_model.dart

class DramaModel {
  final String id;
  final String title;
  final String poster;
  final String? banner;
  final String description;
  final double rating;
  final String status;
  final String platform;
  final int totalEpisodes;

  DramaModel({
    required this.id,
    required this.title,
    required this.poster,
    this.banner,
    required this.description,
    required this.rating,
    required this.status,
    required this.platform,
    required this.totalEpisodes,
  });

  factory DramaModel.fromJson(Map<String, dynamic> json, String platform) {
    return DramaModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Tanpa Judul',
      poster: json['poster']?.toString() ?? '',
      banner: json['banner']?.toString(),
      description: json['description']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      status: json['status']?.toString() ?? 'Unknown',
      platform: platform,
      totalEpisodes: int.tryParse(json['total_episodes']?.toString() ?? '0') ?? 0,
    );
  }
}
