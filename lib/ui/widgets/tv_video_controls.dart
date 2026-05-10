import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'tv_player_dialogs.dart';

class TvVideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final String title;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const TvVideoControls({
    super.key,
    required this.controller,
    required this.title,
    this.onPrevious,
    this.onNext,
  });

  @override
  State<TvVideoControls> createState() => _TvVideoControlsState();
}

class _TvVideoControlsState extends State<TvVideoControls> {
  bool _visible = true;
  Timer? _hideTimer;
  final FocusNode _mainFocusNode = FocusNode();

  // State untuk setelan video player
  String _currentSubtitle = "Off";
  String _currentQuality = "Auto";
  String _currentScreenMode = "Fit";
  String _currentAudio = "Original";
  bool _isAutoNext = true;

  // Daftar tombol navbar kontrol (Urutan sesuai request)
  // 0: Prev, 1: Play/Pause, 2: Next, 3: Subtitle, 4: Quality, 5: Screen Mode, 6: Auto Next, 7: Audio Track, 8: Episode List
  int _focusedButtonIndex = 1; // Default fokus awal ke Play/Pause (Index 1)

  @override
  void initState() {
    super.initState();
    _startHideTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainFocusNode.requestFocus();
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

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      _showControls();
      final key = event.logicalKey;

      // 1. Jika tombol OK (Enter / Select) ditekan pada remote
      if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
        _executeButtonAction(_focusedButtonIndex);
        return KeyEventResult.handled;
      }

      // 2. Navigasi D-Pad Kiri & Kanan untuk menggeser fokus tombol kontrol
      if (key == LogicalKeyboardKey.arrowLeft) {
        if (_focusedButtonIndex > 0) {
          setState(() {
            _focusedButtonIndex--;
          });
        } else {
          // Jika sudah di paling kiri, tekan kiri lagi untuk Rewind video 10 detik
          final newPos = widget.controller.value.position - const Duration(seconds: 10);
          widget.controller.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
        }
        return KeyEventResult.handled;
      }

      if (key == LogicalKeyboardKey.arrowRight) {
        if (_focusedButtonIndex < 8) {
          setState(() {
            _focusedButtonIndex++;
          });
        } else {
          // Jika sudah di paling kanan, tekan kanan lagi untuk Fast Forward video 10 detik
          final newPos = widget.controller.value.position + const Duration(seconds: 10);
          final maxDur = widget.controller.value.duration;
          widget.controller.seekTo(newPos > maxDur ? maxDur : newPos);
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // Eksekusi fungsi masing-masing tombol dari 9 menu premium
  void _executeButtonAction(int index) {
    switch (index) {
      case 0: // Previous Episode
        if (widget.onPrevious != null) widget.onPrevious!();
        break;
      case 1: // Play / Pause
        if (widget.controller.value.isPlaying) {
          widget.controller.pause();
        } else {
          widget.controller.play();
        }
        setState(() {});
        break;
      case 2: // Next Episode
        if (widget.onNext != null) widget.onNext!();
        break;
      case 3: // Subtitle
        _showOptionDialog("Pilih Subtitle", ["Indonesia", "English", "Off"], _currentSubtitle, (val) {
          setState(() => _currentSubtitle = val);
        });
        break;
      case 4: // Quality
        _showOptionDialog("Kualitas Video", ["Auto", "360p", "480p", "720p", "1080p"], _currentQuality, (val) {
          setState(() => _currentQuality = val);
        });
        break;
      case 5: // Screen Mode
        _showOptionDialog("Mode Layar", ["Fit", "Fill", "Stretch", "Zoom"], _currentScreenMode, (val) {
          setState(() => _currentScreenMode = val);
        });
        break;
      case 6: // Auto Next
        setState(() {
          _isAutoNext = !_isAutoNext;
        });
        break;
      case 7: // Audio Track
        _showOptionDialog("Audio Track", ["Bahasa Indonesia", "Original", "English"], _currentAudio, (val) {
          setState(() => _currentAudio = val);
        });
        break;
      case 8: // Episode List
        // Menutup overlay dan memberi sinyal untuk menampilkan daftar episode
        setState(() => _visible = false);
        break;
    }
  }

  void _showOptionDialog(String title, List<String> options, String current, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (context) => TvPlayerDialog(
        title: title,
        options: options,
        currentValue: current,
        onSelected: onSelect,
      ),
    ).then((_) => _mainFocusNode.requestFocus()); // Kembalikan fokus ke player setelah dialog ditutup
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _mainFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _mainFocusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: _showControls,
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Judul Video (Atas)
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

                // 2. Progress Bar (Tengah-Bawah)
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
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          _formatDuration(widget.controller.value.duration),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),

                // 3. 9 Baris Tombol Kontrol Premium (Bawah)
                Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(9, (index) {
                      final isFocused = _focusedButtonIndex == index;
                      return _buildControlButton(index, isFocused);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(int index, bool isFocused) {
    IconData icon;
    String label;

    switch (index) {
      case 0:
        icon = Icons.skip_previous;
        label = "Prev";
        break;
      case 1:
        icon = widget.controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled;
        label = widget.controller.value.isPlaying ? "Pause" : "Play";
        break;
      case 2:
        icon = Icons.skip_next;
        label = "Next";
        break;
      case 3:
        icon = Icons.subtitles;
        label = "Sub: $_currentSubtitle";
        break;
      case 4:
        icon = Icons.hd;
        label = "Res: $_currentQuality";
        break;
      case 5:
        icon = Icons.aspect_ratio;
        label = "Mode: $_currentScreenMode";
        break;
      case 6:
        icon = _isAutoNext ? Icons.autorenew : Icons.play_disabled;
        label = "Auto: ${_isAutoNext ? 'ON' : 'OFF'}";
        break;
      case 7:
        icon = Icons.audiotrack;
        label = "Audio: $_currentAudio";
        break;
      case 8:
        icon = Icons.format_list_bulleted;
        label = "Episodes";
        break;
      default:
        icon = Icons.play_arrow;
        label = "";
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isFocused ? const Color(0xFF00D9FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFocused ? Colors.white : Colors.white10,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isFocused ? Colors.black : Colors.white,
            size: 20,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isFocused ? Colors.black : Colors.white70,
              fontSize: 10,
              fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
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
