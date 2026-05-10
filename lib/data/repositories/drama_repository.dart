// lib/data/repositories/drama_repository.dart

import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../models/drama_model.dart';
import '../models/episode_model.dart';

class DramaRepository {
  final ApiService _apiService;

  DramaRepository(this._apiService);

  // 1. Ambil List Banner Utama (Menyaring platform aktif)
  Future<List<DramaModel>> getBanners() async {
    try {
      final activePlatforms = StorageService.getPlatformSettings();
      final response = await _apiService.client.get('/v2/banner');
      
      if (response.statusCode == 200 && response.data != null) {
        final List dataList = response.data['data'] ?? [];
        
        return dataList.map((item) {
          final String platform = item['platform']?.toString().toLowerCase() ?? '';
          return DramaModel.fromJson(item, platform);
        }).where((drama) {
          // Hanya tampilkan banner dari platform yang bernilai TRUE di setting kelola sumber data
          return activePlatforms[drama.platform] ?? false;
        }).toList();
      }
    } catch (e) {
      print("⚠️ Gagal mengambil banner: $e");
    }
    return [];
  }

  // 2. Ambil Feed Beranda Berdasarkan Kategori & Filter Platform Aktif
  Future<List<DramaModel>> getHomeContent({required String category, int page = 1}) async {
    try {
      final activePlatforms = StorageService.getPlatformSettings();
      
      final response = await _apiService.client.get(
        '/v2/home',
        queryParameters: {
          'category': category,
          'page': page,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List dataList = response.data['data'] ?? [];
        
        return dataList.map((item) {
          final String platform = item['platform']?.toString().toLowerCase() ?? '';
          return DramaModel.fromJson(item, platform);
        }).where((drama) {
          // Saring konten agar hanya menampilkan platform aktif saja
          return activePlatforms[drama.platform] ?? false;
        }).toList();
      }
    } catch (e) {
      print("⚠️ Gagal mengambil konten beranda: $e");
    }
    return [];
  }

  // 3. Ambil Detail Drama Lengkap
  Future<DramaModel?> getDramaDetail(String id, String platform) async {
    try {
      final response = await _apiService.client.get(
        '/v2/detail',
        queryParameters: {
          'id': id,
          'platform': platform,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return DramaModel.fromJson(response.data['data'], platform);
      }
    } catch (e) {
      print("⚠️ Gagal mengambil detail drama: $e");
    }
    return null;
  }

  // 4. Ambil Informasi Detail Video Stream Episode
  Future<EpisodeModel?> getEpisodeVideo(String dramaId, String episodeId, String platform) async {
    try {
      final response = await _apiService.client.get(
        '/v2/video',
        queryParameters: {
          'id': dramaId,
          'episode_id': episodeId,
          'platform': platform,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return EpisodeModel.fromJson(response.data['data']);
      }
    } catch (e) {
      print("⚠️ Gagal mengambil link video streaming: $e");
    }
    return null;
  }
}
