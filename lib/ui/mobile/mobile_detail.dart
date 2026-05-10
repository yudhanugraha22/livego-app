import 'package:flutter/material.dart';
import '../../core/services/cache_service.dart';
import '../../data/models/drama_model.dart';
import '../../data/repositories/drama_repository.dart';
import '../widgets/adaptive_video_player.dart';
import '../widgets/resume_prompt_dialog.dart';

class MobileDetail extends StatefulWidget {
  final DramaModel drama;

  const MobileDetail({super.key, required this.drama});

  @override
  State<MobileDetail> createState() => _MobileDetailState();
}

class _MobileDetailState extends State<MobileDetail> {
  final DramaRepository _repository = DramaRepository();
  List<EpisodeModel> _episodes = [];
  bool _isLoading = true;
  final Map<String, int> _episodeProgress = {}; // Menyimpan progres tontonan per episode

  @override
  void initState() {
    super.initState();
    _loadEpisodesAndProgress();
  }

  Future<void> _loadEpisodesAndProgress() async {
    final episodesData = await _repository.getEpisodes(widget.drama.id);
    final historyMap = await CacheService.getAllHistory();

    // Ambil progres tontonan untuk masing-masing episode drama ini
    for (var ep in episodesData) {
      final history = await CacheService.getHistory(widget.drama.id);
      if (history != null && history.episodeId == ep.id) {
        if (history.durationMs > 0) {
          final percentage = ((history.positionMs / history.durationMs) * 100).round();
          _episodeProgress[ep.id] = percentage;
        }
      }
    }

    setState(() {
      _episodes = episodesData;
      _isLoading = false;
    });
  }

  // Fungsi pengecekan durasi tonton & pemanggilan Resume Prompt untuk Mobile
  Future<void> _handleEpisodeSelection(EpisodeModel episode) async {
    final history = await CacheService.getHistory(widget.drama.id);

    if (history != null && history.episodeId == episode.id && history.positionMs > 5000) {
      // Jika ada progress lebih dari 5 detik, tampilkan dialog kelanjutan
      final minutes = (history.positionMs ~/ 60000).toString().padLeft(2, '0');
      final seconds = ((history.positionMs % 60000) ~/ 1000).toString().padLeft(2, '0');
      final formattedTime = "$minutes:$seconds";

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ResumePromptDialog(
            title: "Lanjutkan Menonton?",
            formattedTime: formattedTime,
            onResume: () => _playVideo(episode, history.positionMs),
            onRestart: () => _playVideo(episode, 0),
          ),
        );
      }
    } else {
      _playVideo(episode, 0);
    }
  }

  void _playVideo(EpisodeModel episode, int startPositionMs) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdaptiveVideoPlayer(
          videoUrl: episode.videoUrl ?? "",
          dramaId: widget.drama.id,
          episodeId: episode.id,
          title: "${widget.drama.title} - ${episode.title}",
          platform: widget.drama.platform,
          isTv: false,
        ),
      ),
    ).then((_) {
      // Refresh progress setelah kembali dari pemutar video
      _loadEpisodesAndProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090615),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
              ),
            )
          : CustomScrollView(
              slivers: [
                // 1. Header Banner Atas (SliverAppBar Neon)
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: const Color(0xFF0D0A1E),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.drama.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1E1B30), Color(0xFF090615)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, const Color(0xFF090615).withOpacity(0.95)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Deskripsi & Detail Info Drama
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D9FF).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF00D9FF), width: 1),
                              ),
                              child: Text(
                                widget.drama.platform.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF00D9FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "• Full HD 1080p",
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Sinopsis Drama",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Menyajikan petualangan seru dengan visual memanjakan mata dan alur cerita yang mendebarkan. Tonton semua episodenya sekarang dengan kualitas terbaik tanpa hambatan iklan.",
                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "DAFTAR EPISODE",
                          style: TextStyle(
                            color: Color(0xFFFF007F),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // 3. List Episode dengan Progress Bar Neon
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final episode = _episodes[index];
                      final progress = _episodeProgress[episode.id];

                      return Card(
                        color: const Color(0xFF131026),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.white10, width: 1),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _handleEpisodeSelection(episode),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.play_circle_outline, color: Color(0xFF00D9FF), size: 28),
                                        const SizedBox(width: 12),
                                        Text(
                                          episode.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                                  ],
                                ),
                                // Jika ada progres menonton, tampilkan progress bar neon tipis di bawahnya
                                if (progress != null && progress > 0) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: progress / 100,
                                            backgroundColor: Colors.white10,
                                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                                            minHeight: 4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "$progress%",
                                        style: const TextStyle(color: Color(0xFF00D9FF), fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _episodes.length,
                  ),
                ),
              ],
            ),
    );
  }
}
