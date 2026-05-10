import '../../data/models/episode_model.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/services/cache_service.dart';
import 'tv_video_controls.dart';

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

  // State navigasi TV baru sesuai blueprint
  bool _showNavbar = false;
  bool _showEpisodeDrawer = false;
  bool _showNextCountdown = false;
  int _countdownSeconds = 5;
  Timer? _countdownTimer;
  bool _hasTriggeredNext = false;
  final FocusNode _tvInputNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    if (widget.isTv) {
      _tvInputNode.requestFocus();
    }
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();

    final savedHistory = await CacheService.getHistory(widget.dramaId);
    if (savedHistory != null && savedHistory.episodeId == widget.episodeId) {
      await _videoPlayerController.seekTo(Duration(milliseconds: savedHistory.positionMs));
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      showControls: !widget.isTv, // Matikan kontrol bawaan Chewie di TV
      deviceOrientationsAfterFullScreen: [
        widget.isTv ? DeviceOrientation.landscapeLeft : DeviceOrientation.portraitUp,
      ],
      placeholder: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
        ),
      ),
    );

    _videoPlayerController.addListener(_videoListener);
    WakelockPlus.enable();

    setState(() {
      _isInitialized = true;
    });
  }

  void _videoListener() {
    if (_videoPlayerController.value.isPlaying) {
      final currentPosition = _videoPlayerController.value.position.inMilliseconds;
      final totalDuration = _videoPlayerController.value.duration.inMilliseconds;

      CacheService.saveHistory(
        dramaId: widget.dramaId,
        episodeId: widget.episodeId,
        platform: widget.platform,
        title: widget.title,
        positionMs: currentPosition,
        durationMs: totalDuration,
      );

      // Cek apakah video sisa 5 detik lagi (5000 milidetik)
      final remainingMs = totalDuration - currentPosition;
      if (remainingMs <= 5000 && remainingMs > 0 && !_showNextCountdown && !_hasTriggeredNext) {
        _startNextEpisodeCountdown();
      }
    }
  }

  void _startNextEpisodeCountdown() {
    setState(() {
      _showNextCountdown = true;
      _countdownSeconds = 5;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_countdownSeconds > 1) {
          _countdownSeconds--;
        } else {
          timer.cancel();
          _showNextCountdown = false;
          _hasTriggeredNext = true;
          _playNextEpisodeAutomatically();
        }
      });
    });
  }

  void _playNextEpisodeAutomatically() {
    // Fungsi ini akan mencari episode selanjutnya secara otomatis.
    // Sementara kita simulasikan kembali memutar video atau memberikan sinyal selesai.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Memutar Episode Berikutnya..."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Menangani input remote TV (D-Pad & Back Button) secara komprehensif
  KeyEventResult _handleTvRemote(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      // 1. Jika tombol BACK ditekan
      if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
        if (_showNavbar || _showEpisodeDrawer) {
          setState(() {
            _showNavbar = false;
            _showEpisodeDrawer = false;
          });
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored; // Biarkan keluar ke halaman detail
      }

      // Jika ada overlay aktif, biarkan dikontrol oleh sub-widget (TvVideoControls)
      if (_showNavbar || _showEpisodeDrawer) {
        return KeyEventResult.ignored;
      }

      // 2. Tombol ATAS (↑): Tampilkan Navbar Kontrol
      if (key == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _showNavbar = true;
        });
        return KeyEventResult.handled;
      }

      // 3. Tombol BAWAH (↓): Tampilkan Laci Daftar Episode
      if (key == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _showEpisodeDrawer = true;
        });
        return KeyEventResult.handled;
      }

      // 4. Tombol KIRI (←): Mundur 10 detik instan
      if (key == LogicalKeyboardKey.arrowLeft) {
        final newPos = _videoPlayerController.value.position - const Duration(seconds: 10);
        _videoPlayerController.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
        return KeyEventResult.handled;
      }

      // 5. Tombol KANAN (→): Maju 10 detik instan
      if (key == LogicalKeyboardKey.arrowRight) {
        final newPos = _videoPlayerController.value.position + const Duration(seconds: 10);
        final maxDur = _videoPlayerController.value.duration;
        _videoPlayerController.seekTo(newPos > maxDur ? maxDur : newPos);
        return KeyEventResult.handled;
      }

      // 6. Tombol OK: Play / Pause instan
      if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
        if (_videoPlayerController.value.isPlaying) {
          _videoPlayerController.pause();
        } else {
          _videoPlayerController.play();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // Kontrol gestur sentuh double tap khusus HP
  void _handleDoubleTapMobile(TapUpDetails details, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < width / 2) {
      // Tap Kiri: Mundur 10 detik
      final newPos = _videoPlayerController.value.position - const Duration(seconds: 10);
      _videoPlayerController.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
    } else {
      // Tap Kanan: Maju 10 detik
      final newPos = _videoPlayerController.value.position + const Duration(seconds: 10);
      final maxDur = _videoPlayerController.value.duration;
      _videoPlayerController.seekTo(newPos > maxDur ? maxDur : newPos);
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    if (!widget.isTv) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    _countdownTimer?.cancel();
    _videoPlayerController.removeListener(_videoListener);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _tvInputNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget playerWidget = _isInitialized && _chewieController != null
        ? AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Chewie(controller: _chewieController!),

                // UI Overlay untuk TV
                if (widget.isTv && _showNavbar)
                  TvVideoControls(
                    controller: _videoPlayerController,
                    title: widget.title,
                  ),

                // Drawer Episode TV (Laci Bawah)
                if (widget.isTv && _showEpisodeDrawer)
                  _buildTvEpisodeDrawer(),

                // Overlay Hitung Mundur Episode Selanjutnya (Next Episode Countdown)
                if (_showNextCountdown)
                  Positioned(
                    bottom: widget.isTv ? 180 : 80,
                    right: 24,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xEE0D0A1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF007F), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF007F).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.next_plan, color: Color(0xFFFF007F), size: 20),
                          const SizedBox(width: 10),
                          Text(
                            "Next Episode in $_countdownSeconds s",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
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
          );

    // Bungkus dengan detector input remote jika di TV, atau gesture detector jika di HP
    if (widget.isTv) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Focus(
          focusNode: _tvInputNode,
          onKeyEvent: _handleTvRemote,
          child: Center(child: playerWidget),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onDoubleTapUp: (details) => _handleDoubleTapMobile(details, context),
          child: Center(child: playerWidget),
        ),
      );
    }
  }

  // Desain laci episode TV yang meluncur dari bawah layar saat tombol bawah ditekan
  Widget _buildTvEpisodeDrawer() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 150,
        color: const Color(0xEE0D0A1E),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daftar Episode",
              style: TextStyle(color: Color(0xFF00D9FF), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10, // Sesuai dengan batasan simulasi episode
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white10,
                    margin: const EdgeInsets.only(right: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Center(
                        child: Text(
                          "Episode ${index + 1}",
                          style: const TextStyle(color: Colors.white),
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
    );
  }
}
