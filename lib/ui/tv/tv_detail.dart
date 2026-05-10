import "../widgets/adaptive_video_player.dart";
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/drama_model.dart';
import '../../data/models/episode_model.dart';
import '../../data/repositories/drama_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    final episodes = await _repository.getEpisodes(widget.drama.id);
    setState(() {
      _episodes = episodes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090615),
      body: Row(
        children: [
          // 1. Sisi Kiri: Poster Besar dengan Efek Glow Neon
          Container(
            width: 320,
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 380,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00D9FF),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D9FF).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: widget.drama.poster,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Sisi Kanan: Detail Informasi & Daftar Episode (Remote Friendly)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 48, 48, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button TV
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1B30),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Kembali'),
                  ),
                  const SizedBox(height: 16),

                  // Judul & Badge Platform
                  Row(
                    children: [
                      Text(
                        widget.drama.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.drama.platform == 'CineFlow'
                              ? const Color(0xFF00D9FF)
                              : const Color(0xFFFF007F),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.drama.platform,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Rating Info
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.drama.rating} / 10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        'Total: ${widget.drama.totalEpisodes} Episode',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sinopsis
                  Text(
                    widget.drama.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section Title Episode
                  const Text(
                    'Pilih Episode (Gunakan D-Pad Remote)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List Episode Mendatar
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _episodes.length,
                            itemBuilder: (context, index) {
                              final ep = _episodes[index];
                              final isFocused = _focusedEpisodeIndex == index;

                              return InkWell(
                                onFocusChange: (hasFocus) {
                                  if (hasFocus) {
                                    setState(() {
                                      _focusedEpisodeIndex = index;
                                    });
                                  }
                                },
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdaptiveVideoPlayer(videoUrl: ep.videoUrl ?? "", dramaId: widget.drama.id, episodeId: ep.id, title: "${widget.drama.title} - ${ep.title}", platform: widget.drama.platform, isTv: true)));
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 140,
                                  margin: const EdgeInsets.only(right: 16, bottom: 20),
                                  decoration: BoxDecoration(
                                    color: isFocused
                                        ? const Color(0xFF00D9FF)
                                        : const Color(0xFF1E1B30),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isFocused
                                          ? Colors.white
                                          : Colors.white12,
                                      width: 2,
                                    ),
                                    boxShadow: isFocused
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF00D9FF).withOpacity(0.4),
                                              blurRadius: 10,
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      ep.title,
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
