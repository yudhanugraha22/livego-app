// lib/ui/mobile/mobile_player.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../core/services/api_service.dart';
import '../../core/services/cache_service.dart';
import '../../data/models/episode_model.dart';
import '../../data/repositories/drama_repository.dart';

class MobilePlayer extends StatefulWidget {
  final String dramaId;
  final String episodeId;
  final String platform;

  const MobilePlayer({
    super.key,
    required this.dramaId,
    required this.episodeId,
    required this.platform,
  });

  @override
  State<MobilePlayer> createState() => _MobilePlayerState();
}

class _MobilePlayerState extends State<MobilePlayer> {
  late final DramaRepository _repository;
  VideoPlayerController? _controller;
  EpisodeModel? _episode;
  bool _isLoading = true;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _repository = DramaRepository(ApiService());
    
    // Paksa layar ke mode landscape saat memutar video
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _loadVideo();
  }

  Future<void> _loadVideo() async {
    final epData = await _repository.getEpisodeVideo(widget.dramaId, widget.episodeId, widget.platform);
    if (epData != null && epData.videoUrl != null) {
      _episode = epData;
      _controller = VideoPlayerController.networkUrl(Uri.parse(epData.videoUrl!));
      
      try {
        await _controller!.initialize();
        
        // Cek riwayat tontonan terakhir dari SQLite untuk me-resume video
        final history = await CacheService.getHistory(widget.dramaId);
        if (history != null && history.episodeId == widget.episodeId) {
          await _controller!.seekTo(Duration(milliseconds: history.positionMs));
        }

        _controller!.play();
        _controller!.addListener(_videoListener);
      } catch (e) {
        print("⚠️ Gagal memutar video: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  void _videoListener() {
    if (_controller != null && _controller!.value.isInitialized) {
      // Simpan progress menonton ke database SQLite secara realtime tiap interval waktu
      CacheService.saveHistory(
        dramaId: widget.dramaId,
        episodeId: widget.episodeId,
        platform: widget.platform,
        title: _episode?.title ?? 'Episode ${widget.episodeId}',
        poster: '', // Bisa ditambahkan URL poster drama jika diperlukan
        episodeNumber: int.tryParse(widget.episodeId) ?? 1,
        positionMs: _controller!.value.position.inMilliseconds,
        durationMs: _controller!.value.duration.inMilliseconds,
      );
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    
    // Kembalikan orientasi layar ke portrait saat keluar player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF)))
          : _controller == null || !_controller!.value.isInitialized
              ? _buildErrorUI()
              : GestureDetector(
                  onTap: () {
                    setState(() => _showControls = !_showControls);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video Render Layer
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),

                      // Overlay Kontrol Layar Sentuh HP
                      if (_showControls) _buildControlsOverlay(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      color: Colors.black40,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Baris Atas: Tombol Back & Judul Episode
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                _episode?.title ?? 'Memutar Episode ${widget.episodeId}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Baris Tengah: Play/Pause, Rewind & Forward
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
                onPressed: () {
                  final current = _controller!.value.position;
                  _controller!.seekTo(current - const Duration(seconds: 10));
                },
              ),
              const SizedBox(width: 32),
              IconButton(
                icon: Icon(
                  _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: const Color(0xFF00D9FF),
                  size: 64,
                ),
                onPressed: () {
                  setState(() {
                    _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                  });
                },
              ),
              const SizedBox(width: 32),
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
                onPressed: () {
                  final current = _controller!.value.position;
                  _controller!.seekTo(current + const Duration(seconds: 10));
                },
              ),
            ],
          ),

          // Baris Bawah: Seekbar Progress Video
          Column(
            children: [
              VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF00D9FF),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white10,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_controller!.value.position),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    _formatDuration(_controller!.value.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          const Text('Gagal memuat link streaming video.', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }
}
