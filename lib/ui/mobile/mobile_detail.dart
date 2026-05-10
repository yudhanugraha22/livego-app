import "../widgets/adaptive_video_player.dart";
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/drama_model.dart';
import '../../data/models/episode_model.dart';
import '../../data/repositories/drama_repository.dart';

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Banner
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.drama.banner ?? widget.drama.poster,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF0F0C1B).withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            // Detail Konten
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.drama.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.drama.platform == 'CineFlow'
                              ? const Color(0xFF00D9FF)
                              : const Color(0xFFFF007F),
                          borderRadius: BorderRadius.circular(4),
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
                      const SizedBox(width: 12),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.drama.rating}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${widget.drama.totalEpisodes} Episode',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.drama.description,
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Daftar Episode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _episodes.length,
                          itemBuilder: (context, index) {
                            final ep = _episodes[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1B30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.play_circle_fill, color: Color(0xFF00D9FF)),
                                title: Text(
                                  ep.title,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdaptiveVideoPlayer(videoUrl: ep.videoUrl ?? "", dramaId: widget.drama.id, episodeId: ep.id, title: "${widget.drama.title} - ${ep.title}", platform: widget.drama.platform, isTv: false)));
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
