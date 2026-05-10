import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class TvVideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final String title;

  const TvVideoControls({
    super.key,
    required this.controller,
    required this.title,
  });

  @override
  State<TvVideoControls> createState() => _TvVideoControlsState();
}

class _TvVideoControlsState extends State<TvVideoControls> {
  bool _visible = true;
  Timer? _hideTimer;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _startHideTimer();
    // Berikan fokus ke widget ini agar langsung bisa membaca remote TV
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _visible = false;
        });
      }
    });
  }

  void _showControls() {
    setState(() {
      _visible = true;
    });
    _startHideTimer();
  }

  // Fungsi untuk membaca tombol remote TV (D-Pad)
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      _showControls(); // Setiap kali tombol ditekan, tampilkan kontrol

      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.gameButtonSelect) {
        // Klik tengah remote: Play / Pause
        if (widget.controller.value.isPlaying) {
          widget.controller.pause();
        } else {
          widget.controller.play();
        }
        setState(() {});
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        // Tekan kiri remote: Rewind 10 detik
        final newPos = widget.controller.value.position - const Duration(seconds: 10);
        widget.controller.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowRight) {
        // Tekan kanan remote: Fast Forward 10 detik
        final newPos = widget.controller.value.position + const Duration(seconds: 10);
        final maxDur = widget.controller.value.duration;
        widget.controller.seekTo(newPos > maxDur ? maxDur : newPos);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: _showControls,
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: Colors.black45,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bagian Atas: Judul Drama & Episode
                Row(
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Bagian Tengah: Indikator Play / Pause Neon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.controller.value.isPlaying 
                          ? Icons.play_arrow 
                          : Icons.pause,
                      size: 64,
                      color: const Color(0xFF00D9FF),
                    ),
                  ],
                ),

                // Bagian Bawah: Progress Bar Tontonan
                Column(
                  children: [
                    VideoProgressIndicator(
                      widget.controller,
                      allowScrubbing: false,
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
                          _formatDuration(widget.controller.value.position),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          _formatDuration(widget.controller.value.duration),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
