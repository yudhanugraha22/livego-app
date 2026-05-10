// lib/ui/tv/tv_player.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/services/api_service.dart';
import '../../core/services/cache_service.dart';
import '../../data/models/episode_model.dart';
import '../../data/repositories/drama_repository.dart';

class TvPlayer extends StatefulWidget {
  final String dramaId;
  final String episodeId;
  final String platform;

  const TvPlayer({
    super.key,
    required this.dramaId,
    required this.episodeId,
    required this.platform,
  });

  @override
  State<TvPlayer> createState() => _TvPlayerState();
}

class _TvPlayerState extends State<TvPlayer> {
  late final DramaRepository _repository;
  VideoPlayerController? _controller;
  EpisodeModel? _episode;
  bool _isLoading = true;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _repository = DramaRepository(ApiService());
    _loadVideo();
    _startHideTimer();
  }

  Future<void> _loadVideo() async {
    final epData = await _repository.getEpisodeVideo(widget.dramaId, widget.episodeId, widget.platform);
    if (epData != null && epData.videoUrl != null) {
      _episode = epData;
      _controller = VideoPlayerController.networkUrl(Uri.parse(epData.videoUrl!));
      
      try {
        await _controller!.initialize();
        
        // Resume posisi tontonan terakhir dari database SQLite
        final history = await CacheService.getHistory(widget.dramaId);
        if (history != null && history.episodeId == widget.episodeId) {
          await _controller!.seekTo(Duration(milliseconds: history.positionMs));
        }

        _controller!.play();
        _controller!.addListener(_videoListener);
      } catch (e) {
        print("⚠️ Gagal memuat video TV: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  void _videoListener() {
    if (_controller != null && _controller!.value.isInitialized) {
      CacheService.saveHistory(
        dramaId: widget.dramaId,
        episodeId: widget.episodeId,
        platform: widget.platform,
        title: _episode?.title ?? 'Episode ${widget.episodeId}',
        poster: '',
        episodeNumber: int.tryParse(widget.episodeId) ?? 1,
        positionMs: _controller!.value.position.inMilliseconds,
        durationMs: _controller!.value.duration.inMilliseconds,
      );
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _triggerControls() {
    setState(() => _showControls = true);
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKey: (event) {
          // Deteksi remote TV ditekan untuk memunculkan panel kontrol
          _triggerControls();
          return KeyEventResult.ignored;
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF)))
            : _controller == null || !_controller!.value.isInitialized
                ? _buildTvErrorUI()
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      // Render Video Player
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),

                      // Kontrol Android TV
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: _showControls ? _buildTvControlsOverlay() : const SizedBox.shrink(),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTvControlsOverlay() {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Tombol back & Judul drama/episode
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              Text(
                _episode?.title ?? 'Episode ${widget.episodeId}',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Tengah: Kontrol Utama (Fokus D-Pad TV)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Focus(
                onKey: (node, event) {
                  if (event.logicalKey.keyLabel == 'Select' || event.logicalKey.keyLabel == 'Enter') {
                    _controller!.seekTo(_controller!.value.position - const Duration(seconds: 10));
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: Builder(builder: (context) {
                  final hasFocus = Focus.of(context).hasFocus;
                  return Icon(Icons.replay_10, color: hasFocus ? const Color(0xFF00D9FF) : Colors.white, size: 48);
                }),
              ),
              const SizedBox(width: 40),
              Focus(
                onKey: (node, event) {
                  if (event.logicalKey.keyLabel == 'Select' || event.logicalKey.keyLabel == 'Enter') {
                    setState(() {
                      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                    });
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: Builder(builder: (context) {
                  final hasFocus = Focus.of(context).hasFocus;
                  return Icon(
                    _controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: hasFocus ? const Color(0xFF00D9FF) : Colors.white,
                    size: 80,
                  );
                }),
              ),
              const SizedBox(width: 40),
              Focus(
                onKey: (node, event) {
                  if (event.logicalKey.keyLabel == 'Select' || event.logicalKey.keyLabel == 'Enter') {
                    _controller!.seekTo(_controller!.value.position + const Duration(seconds: 10));
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: Builder(builder: (context) {
                  final hasFocus = Focus.of(context).hasFocus;
                  return Icon(Icons.forward_10, color: hasFocus ? const Color(0xFF00D9FF) : Colors.white, size: 48);
                }),
              ),
            ],
          ),

          // Bawah: Seekbar Player TV
          Column(
            children: [
              VideoProgressIndicator(
                _controller!,
                allowScrubbing: false, // Di TV, seek dilakukan lewat tombol skip
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF00D9FF),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white10,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_controller!.value.position),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    _formatDuration(_controller!.value.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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

  Widget _buildTvErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.tv_off, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text('Format video tidak didukung atau server sibuk.', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }
}
