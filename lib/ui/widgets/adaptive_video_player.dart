import 'package:flutter/material.dart';
import "tv_video_controls.dart";
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../core/services/cache_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AdaptiveVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String dramaId;
  final String episodeId;
  final String title;
  final String platform;
  final bool isTv;

  const AdaptiveVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.dramaId,
    required this.episodeId,
    required this.title,
    required this.platform,
    required this.isTv,
  });

  @override
  State<AdaptiveVideoPlayer> createState() => _AdaptiveVideoPlayerState();
}

class _AdaptiveVideoPlayerState extends State<AdaptiveVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 1. Inisialisasi controller video
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();

    // 2. Ambil riwayat tontonan terakhir (Auto-Resume)
    final savedHistory = await CacheService.getHistory(widget.dramaId);
    if (savedHistory != null && savedHistory.episodeId == widget.episodeId) {
      // Jika episode sama, lompat ke detik terakhir yang tersimpan
      await _videoPlayerController.seekTo(Duration(milliseconds: savedHistory.positionMs));
    }

    // 3. Konfigurasi Chewie Player (tampilan kontrol video)
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      // Desain kontrol disesuaikan dengan jenis perangkat
      showControls: !widget.isTv, // Sembunyikan kontrol bawaan di TV untuk diganti kontrol remote custom nanti
      deviceOrientationsAfterFullScreen: [
        widget.isTv ? DeviceOrientation.landscapeLeft : DeviceOrientation.portraitUp,
      ],
      placeholder: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
        ),
      ),
    );

    // 4. Tambahkan listener untuk terus menyimpan progress tontonan secara berkala
    _videoPlayerController.addListener(_videoListener);

    // Jaga layar tetap menyala selama pemutar video aktif
    WakelockPlus.enable();
    setState(() {
      _isInitialized = true;
    });
  }

  void _videoListener() {
    if (_videoPlayerController.value.isPlaying) {
      final currentPosition = _videoPlayerController.value.position.inMilliseconds;
      final totalDuration = _videoPlayerController.value.duration.inMilliseconds;

      // Simpan ke cache lokal setiap kali video berjalan
      CacheService.saveHistory(
        dramaId: widget.dramaId,
        episodeId: widget.episodeId,
        platform: widget.platform,
        title: widget.title,
        positionMs: currentPosition,
        durationMs: totalDuration,
      );
    }
  }

  @override
  void dispose() {
    // Kembalikan orientasi layar saat keluar dari player
    if (!widget.isTv) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    // Kembalikan pengaturan layar agar bisa tidur kembali
    WakelockPlus.disable();
    _videoPlayerController.removeListener(_videoListener);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isInitialized && _chewieController != null
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    Chewie(controller: _chewieController!),
                    if (widget.isTv)
                      TvVideoControls(
                        controller: _videoPlayerController,
                        title: widget.title,
                      ),
                  ],
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Menghubungkan Aliran Video...',
                    style: TextStyle(color: Colors.white70),
                  )
                ],
              ),
      ),
    );
  }
}
