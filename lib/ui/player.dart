import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'widgets.dart';
import 'api_service.dart';

// Halaman Detail (Bridge untuk ke Player)
class DetailPage extends StatefulWidget {
  final String id, source;
  const DetailPage({super.key, required this.id, required this.source});
  @override State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map? d; bool loading = true;
  @override void initState() { super.initState(); _load(); }
  _load() async {
    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) setState(() { d = res['data']; loading = false; });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: loading ? const Center(child: CircularProgressIndicator()) : Stack(
        children: [
          Image.network(d!['cover'], height: double.infinity, width: double.infinity, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.7)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(d!['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TVButton(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerPage(id: widget.id, source: widget.source, ep: "1", title: d!['title']))),
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(30)), child: const Text("PUTAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold))),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// PEMUTAR VIDEO IDENTIK CINEFLOW (TV STYLE)
// ==========================================
class PlayerPage extends StatefulWidget {
  final String id, source, ep, title;
  const PlayerPage({super.key, required this.id, required this.source, required this.ep, required this.title});
  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  bool showControls = true;
  Timer? _hideTimer;
  int focusedIndex = 0; // Untuk navigasi tombol di dalam panel biru

  @override void initState() {
    super.initState();
    _initPlayer();
    _startHideTimer();
  }

  _initPlayer() async {
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=${widget.ep}&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) {
          setState(() { _v!.play(); });
        });
      _v!.addListener(() => setState(() {}));
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      setState(() => showControls = false);
    });
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      setState(() => showControls = true);
      _startHideTimer();

      final k = event.logicalKey;
      if (k == LogicalKeyboardKey.select || k == LogicalKeyboardKey.enter) {
        if (!showControls) {
          setState(() => showControls = true);
        } else {
          // Aksi tombol yang sedang difokuskan di panel biru
          _onButtonPressed(focusedIndex);
        }
      } else if (k == LogicalKeyboardKey.arrowRight) {
        if (showControls) {
          setState(() { if (focusedIndex < 8) focusedIndex++; });
        } else {
          _v!.seekTo(_v!.value.position + const Duration(seconds: 10));
        }
      } else if (k == LogicalKeyboardKey.arrowLeft) {
        if (showControls) {
          setState(() { if (focusedIndex > 0) focusedIndex--; });
        } else {
          _v!.seekTo(_v!.value.position - const Duration(seconds: 10));
        }
      }
    }
  }

  void _onButtonPressed(int index) {
    // Logika tombol: 0=Prev, 1=Next, 2=CC, 3=AUTO, 4=Fit, 5=Refresh, 6=Down, 7=Fav, 8=List
    if (index == 5) _v!.seekTo(Duration.zero); // Contoh Replay
  }

  @override void dispose() { _hideTimer?.cancel(); _v?.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. LAYER VIDEO
            Center(
              child: _v != null && _v!.value.isInitialized
                  ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!))
                  : const CircularProgressIndicator(color: Colors.blueAccent),
            ),

            // 2. HEADER INFO (Sesuai Gambar)
            if (showControls) Positioned(
              top: 40, left: 30, right: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${widget.title} - Episode ${widget.ep}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text("Tonton drama pendek favorit keluarga dengan kualitas terbaik.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),

            // 3. PANEL KONTROL BIRU (IDENTIK CINEFLOW)
            if (showControls) Positioned(
              bottom: 30, left: 30, right: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2A4F).withOpacity(0.9), // Warna biru box CineFlow
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.5), width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress Bar
                    Row(
                      children: [
                        Text(_formatDur(_v!.value.position), style: const TextStyle(color: Colors.white, fontSize: 12)),
                        Expanded(
                          child: Container(
                            height: 6, margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: _v!.value.duration.inSeconds > 0 ? _v!.value.position.inSeconds / _v!.value.duration.inSeconds : 0,
                                backgroundColor: Colors.white12,
                                color: const Color(0xFFD946EF), // Pink/Purple gradient look
                              ),
                            ),
                          ),
                        ),
                        Text(_formatDur(_v!.value.duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Barisan Tombol Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIcon(0, Icons.skip_previous),
                        _buildIcon(1, Icons.skip_next),
                        _buildIcon(2, Icons.subtitles),
                        _buildTextIcon(3, "AUTO"),
                        _buildIcon(4, Icons.aspect_ratio),
                        _buildIcon(5, Icons.refresh),
                        _buildIcon(6, Icons.download),
                        _buildIcon(7, Icons.favorite_border),
                        _buildIcon(8, Icons.list),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(int index, IconData icon) {
    bool isFocused = focusedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isFocused ? Colors.white24 : Colors.transparent,
        shape: BoxShape.circle,
        border: isFocused ? Border.all(color: Colors.cyan, width: 2) : null,
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _buildTextIcon(int index, String text) {
    bool isFocused = focusedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFocused ? Colors.white24 : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isFocused ? Colors.cyan : Colors.white24, width: 1.5),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  String _formatDur(Duration d) => "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
}
