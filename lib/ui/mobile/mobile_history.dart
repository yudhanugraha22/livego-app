import 'package:flutter/material.dart';
import '../../core/services/cache_service.dart';
import '../../data/models/drama_model.dart';
import '../../data/repositories/drama_repository.dart';
import '../widgets/adaptive_video_player.dart';

class MobileHistory extends StatefulWidget {
  const MobileHistory({super.key});

  @override
  State<MobileHistory> createState() => _MobileHistoryState();
}

class _MobileHistoryState extends State<MobileHistory> {
  List<Map<String, dynamic>> _historyList = [];
  bool _isLoading = true;
  final DramaRepository _dramaRepository = DramaRepository();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // Mengambil semua riwayat tontonan dari CacheService
    final historyMap = await CacheService.getAllHistory();
    List<Map<String, dynamic>> tempHistory = [];

    for (var entry in historyMap.entries) {
      final dramaId = entry.key;
      final history = entry.value;
      
      tempHistory.add({
        'dramaId': dramaId,
        'episodeId': history.episodeId,
        'title': history.title,
        'platform': history.platform,
        'positionMs': history.positionMs,
        'durationMs': history.durationMs,
      });
    }

    setState(() {
      _historyList = tempHistory;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RIWAYAT TONTONAN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color(0xFF00D9FF),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
              ),
            )
          : _historyList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada riwayat tontonan.',
                    style: TextStyle(color: Colors.white30, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _historyList.length,
                  itemBuilder: (context, index) {
                    final item = _historyList[index];
                    final progress = item['durationMs'] > 0 
                        ? (item['positionMs'] / item['durationMs']) 
                        : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.history,
                                color: Color(0xFF00D9FF),
                                size: 28,
                              ),
                              title: Text(
                                item['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Platform: ${item['platform']} • Episode ${item['episodeId'].split('_').last}',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              trailing: const Icon(
                                Icons.play_circle_fill,
                                color: Color(0xFF00D9FF),
                                size: 32,
                              ),
                              onTap: () async {
                                // Ambil URL video riil dari repository simulasi kita
                                final episodes = await _dramaRepository.getEpisodes(item['dramaId']);
                                final targetEp = episodes.firstWhere(
                                  (ep) => ep.id == item['episodeId'],
                                  orElse: () => episodes.first,
                                );

                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdaptiveVideoPlayer(
                                        videoUrl: targetEp.videoUrl ?? "",
                                        dramaId: item['dramaId'],
                                        episodeId: item['episodeId'],
                                        title: item['title'],
                                        platform: item['platform'],
                                        isTv: false,
                                      ),
                                    ),
                                  ).then((_) => _loadHistory()); // Refresh riwayat saat kembali
                                }
                              },
                            ),
                            // Progress bar neon tontonan terakhir
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                              minHeight: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
