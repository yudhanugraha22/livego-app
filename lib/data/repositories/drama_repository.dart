import '../models/drama_model.dart';
import '../models/episode_model.dart';

class DramaRepository {
  // Simulasi data Banner Utama (Slider)
  Future<List<DramaModel>> getBanners() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      DramaModel(
        id: '1',
        title: 'Love Between Fairy and Devil',
        poster: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500',
        banner: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=1000',
        description: 'Kisah cinta terlarang antara peri pemberani dan raja iblis agung yang kejam.',
        rating: 9.5,
        status: 'TAMAT',
        platform: 'CineFlow',
        totalEpisodes: 36,
      ),
      DramaModel(
        id: '2',
        title: 'Hidden Love',
        poster: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500',
        banner: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1000',
        description: 'Perjalanan cinta manis tersembunyi Sang Zhi kepada teman dekat kakaknya selama bertahun-tahun.',
        rating: 9.8,
        status: 'TAMAT',
        platform: 'Melolo',
        totalEpisodes: 25,
      ),
    ];
  }

  // Simulasi daftar Drama Rekomendasi
  Future<List<DramaModel>> getDramas() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      DramaModel(
        id: '1',
        title: 'Love Between Fairy and Devil',
        poster: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500',
        description: 'Kisah cinta terlarang peri dan raja iblis.',
        rating: 9.5,
        status: 'TAMAT',
        platform: 'CineFlow',
        totalEpisodes: 36,
      ),
      DramaModel(
        id: '2',
        title: 'Hidden Love',
        poster: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500',
        description: 'Kisah romantis Sang Zhi yang jatuh cinta diam-diam.',
        rating: 9.8,
        status: 'TAMAT',
        platform: 'Melolo',
        totalEpisodes: 25,
      ),
      DramaModel(
        id: '3',
        title: 'Till The End of The Moon',
        poster: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500',
        description: 'Demi menyelamatkan dunia dari raja iblis, seorang dewi dikirim ke masa lalu.',
        rating: 9.6,
        status: 'TAMAT',
        platform: 'CineFlow',
        totalEpisodes: 40,
      ),
      DramaModel(
        id: '4',
        title: 'The Double',
        poster: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
        description: 'Pembalasan dendam seorang putri bangsawan yang kehilangan segalanya.',
        rating: 9.4,
        status: 'ONGOING',
        platform: 'Melolo',
        totalEpisodes: 40,
      ),
    ];
  }

  // Simulasi daftar episode drama
  Future<List<EpisodeModel>> getEpisodes(String dramaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.generate(
      10,
      (index) => EpisodeModel(
        id: '${dramaId}_ep_${index + 1}',
        title: 'Episode ${index + 1}',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        episodeNumber: index + 1,
      ),
    );
  }

  // Mengambil daftar drama populer (menggunakan fungsi getHomeContent bawaan Anda)
  Future<List<DramaModel>> getPopularDramas() async {
    try {
      // Jika repository Anda menggunakan nama method berbeda (misal: getHome atau getDramas), 
      // silakan ganti pemanggilan di bawah ini. Secara default kita panggil getHomeContent().
      return await getHomeContent();
    } catch (_) {
      // Fallback jika terjadi error
      return [];
    }
  }

  // Mengambil daftar episode berdasarkan dramaId
  Future<List<EpisodeModel>> getEpisodes(String dramaId) async {
    try {
      final detail = await getDramaDetail(dramaId);
      // Menyesuaikan dengan variabel list episode di detail drama Anda
      return detail.episodes ?? [];
    } catch (_) {
      return [];
    }
  }

}