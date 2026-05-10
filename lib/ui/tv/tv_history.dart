import 'package:flutter/material.dart';
import '../../core/services/cache_service.dart';
import '../../data/models/drama_model.dart';
import '../../data/repositories/drama_repository.dart';
import '../widgets/adaptive_video_player.dart';

class TvHistory extends StatefulWidget {
  const TvHistory({super.key});

  @override
  State<TvHistory> createState() => _TvHistoryState();
}

class _TvHistoryState extends State<TvHistory> {
  List<Map<String, dynamic>> _historyList = [];
  bool _isLoading = true;
  int _focusedIndex = 0;
  final DramaRepository _dramaRepository = DramaRepository();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
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
      backgroundColor: const Color(0xFF090615),
      body: Row(
        children: [
          // Sidebar Navigasi Kiri (TV)
          Container(
            width: 80,
            color: const Color(0xFF0D0A1E),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white38, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 32),
                IconButton(
                  icon: const Icon(Icons.history, color: Color(0xFF00D9FF), size: 30),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Konten Utama Kanan
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lanjutkan Menonton (Riwayat)',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                          ),
                        )
                      : _historyList.isEmpty
                          ? const Center(
                              child: Text(
                                'Belum ada riwayat tontonan.',
                                style: TextStyle(color: Colors.white24, fontSize: 18),
                              ),
                            )
                          : Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.8,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: _historyList.length,
                                itemBuilder: (context, index) {
                                  final item = _historyList[index];
                                  final isFocused = _focusedIndex == index;
                                  final progress = item['durationMs'] > 0 
                                      ? (item['positionMs'] / item['durationMs']) 
                                      : 0.0;

                                  return InkWell(
                                    onFocusChange: (hasFocus) {
                                      if (hasFocus) {
                                        setState(() {
                                          _focusedIndex = index;
                                        });
                                      }
                                    },
                                    onTap: () async {
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
                                              isTv: true,
                                            ),
                                          ),
                                        ).then((_) => _loadHistory());
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      decoration: BoxDecoration(
                                        color: isFocused ? const Color(0xFF00D9FF) : const Color(0xFF1E1B30),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isFocused ? Colors.white : Colors.white10,
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['title'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isFocused ? Colors.black : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Platform: ${item['platform']}',
                                                style: TextStyle(
                                                  color: isFocused ? Colors.black54 : Colors.white60,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          LinearProgressIndicator(
                                            value: progress,
                                            backgroundColor: Colors.white24,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              isFocused ? Colors.black : const Color(0xFF00D9FF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
