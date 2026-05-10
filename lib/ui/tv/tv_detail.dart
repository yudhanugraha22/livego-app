import '../../data/models/episode_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/cache_service.dart';
import '../../data/models/drama_model.dart';
import '../../data/repositories/drama_repository.dart';
import '../widgets/adaptive_video_player.dart';
import '../widgets/resume_prompt_dialog.dart';

class TvDetail extends StatefulWidget {
  final DramaModel drama;

  const TvDetail({super.key, required this.drama});

  @override
  State<TvDetail> createState() => _TvDetailState();
}

class _TvDetailState extends State<TvDetail> {
  final DramaRepository _repository = DramaRepository();
  List<EpisodeModel> _episodes = [];
  bool _isLoading = true;
  int _focusedEpisodeIndex = 0;
  final FocusNode _firstEpisodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    final data = await _repository.getEpisodes(widget.drama.id);
    setState(() {
      _episodes = data;
      _isLoading = false;
    });
    // Berikan jeda sedikit agar UI ter-render, baru fokuskan tombol episode pertama
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_firstEpisodeFocusNode.canRequestFocus) {
        _firstEpisodeFocusNode.requestFocus();
      }
    });
  }

  // Fungsi pengecekan durasi tonton & pemanggilan Resume Prompt
  Future<void> _handleEpisodeSelection(EpisodeModel episode) async {
    final history = await CacheService.getHistory(widget.drama.id);

    if (history != null && history.episodeId == episode.id && history.positionMs > 5000) {
      // Jika ada progres tonton lebih dari 5 detik, tampilkan prompt kelanjutan
      final minutes = (history.positionMs ~/ 60000).toString().padLeft(2, '0');
      final seconds = ((history.positionMs % 60000) ~/ 1000).toString().padLeft(2, '0');
      final formattedTime = "$minutes:$seconds";

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ResumePromptDialog(
            title: "Lanjutkan Tontonan?",
            formattedTime: formattedTime,
            onResume: () => _playVideo(episode, history.positionMs),
            onRestart: () => _playVideo(episode, 0),
          ),
        );
      }
    } else {
      // Jika tidak ada riwayat, langsung play dari awal (detik 0)
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
          isTv: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstEpisodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090615),
      body: Row(
        children: [
          // Bagian Kiri: Poster & Deskripsi Drama
          Container(
            width: 320,
            padding: const EdgeInsets.all(32),
            color: const Color(0xFF0D0A1E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.movie, color: Color(0xFF00D9FF), size: 48),
                const SizedBox(height: 16),
                Text(
                  widget.drama.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sumber Platform: ${widget.drama.platform.toUpperCase()}",
                  style: const TextStyle(color: Color(0xFFFF007F), fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Sinopsis singkat atau info drama di TV. Nikmati tontonan dengan resolusi penuh dan audio jernih yang dioptimalkan khusus sistem TV box Anda.",
                  style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),

          // Bagian Kanan: Daftar Episode Grid Ramah D-Pad
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PILIH EPISODE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 1.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _episodes.length,
                            itemBuilder: (context, index) {
                              final episode = _episodes[index];
                              final isFocused = _focusedEpisodeIndex == index;

                              return InkWell(
                                focusNode: index == 0 ? _firstEpisodeFocusNode : null,
                                onFocusChange: (hasFocus) {
                                  if (hasFocus) {
                                    setState(() {
                                      _focusedEpisodeIndex = index;
                                    });
                                  }
                                },
                                onTap: () => _handleEpisodeSelection(episode),
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
                                  child: Center(
                                    child: Text(
                                      episode.title,
                                      style: TextStyle(
                                        color: isFocused ? Colors.black : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
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
