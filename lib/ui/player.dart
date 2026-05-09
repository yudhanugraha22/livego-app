import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'widgets.dart';
import 'api_service.dart';

class PlayerPage extends StatefulWidget {
  final String id, source;
  const PlayerPage({super.key, required this.id, required this.source});

  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  Map? dramaData;
  bool isLoaded = false;
  bool showUI = true;
  int currentEp = 1;
  int focusedIndex = 0; // 0-8 untuk tombol di panel biru
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // LANGKAH 1: Ambil info drama & episode terakhir
  _loadInitialData() async {
    final p = await SharedPreferences.getInstance();
    currentEp = p.getInt('last_ep_${widget.id}') ?? 1;

    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) {
      setState(() { dramaData = res['data']; });
      _initVideo(currentEp);
    }
  }

  // LANGKAH 2: Inisialisasi Video (Langsung Play)
  _initVideo(int ep) async {
    setState(() { isLoaded = false; currentEp = ep; });
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=$ep&lang=id");
    
    if (res != null && res['success']) {
      if (_v != null) await _v!.dispose();
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) {
          setState(() { isLoaded = true; _v!.play(); });
          _startHideTimer();
        });
      
      // Simpan progress otomatis
      final p = await SharedPreferences.getInstance();
      p.setInt('last_ep_${widget.id}', ep);
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => showUI = false);
    });
  }

  void _handleRemote(KeyEvent event) {
    if (event is KeyDownEvent) {
      setState(() => showUI = true);
      _startHideTimer();

      final k = event.logicalKey;
      if (k == LogicalKeyboardKey.select || k == LogicalKeyboardKey.enter) {
        if (!showUI) { setState(() => showUI = true); } 
        else { _onActionClick(focusedIndex); }
      } else if (k == LogicalKeyboardKey.arrowRight) {
        if (showUI) { setState(() { if(focusedIndex < 8) focusedIndex++; }); }
        else { _v!.seekTo(_v!.value.position + const Duration(seconds: 10)); }
      } else if (k == LogicalKeyboardKey.arrowLeft) {
        if (showUI) { setState(() { if(focusedIndex > 0) focusedIndex--; }); }
        else { _v!.seekTo(_v!.value.position - const Duration(seconds: 10)); }
      }
    }
  }

  void _onActionClick(int index) {
    if (index == 0 && currentEp > 1) _initVideo(currentEp - 1);
    if (index == 1 && currentEp < (dramaData?['total_episodes'] ?? 1)) _initVideo(currentEp + 1);
    if (index == 5) _v!.seekTo(Duration.zero); // Refresh/Replay
  }

  @override
  void dispose() { _hideTimer?.cancel(); _v?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _handleRemote,
      child: Scaffold(
        backgroundColor: Colors.black, // Mencegah blank putih
        body: dramaData == null 
        ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        : Stack(
            children: [
              // 1. VIDEO LAYER
              Center(
                child: isLoaded 
                ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!))
                : const CircularProgressIndicator(color: Colors.blueAccent),
              ),

              // 2. HEADER INFO (Sesuai Gambar)
              if (showUI) Positioned(
                top: 40, left: 30, right: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${dramaData!['title']} - Eps $currentEp", 
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(dramaData!['synopsis'] ?? "", 
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                  ],
                ),
              ),

              // 3. PANEL KONTROL IDENTIK CINEFLOW (TV BLUE BOX)
              if (showUI) Positioned(
                bottom: 30, left: 40, right: 40,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2A4F).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress Bar Ungu/Pink
                      Row(
                        children: [
                          Text(_formatDur(_v!.value.position), style: const TextStyle(fontSize: 12)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: LinearProgressIndicator(
                                value: isLoaded && _v!.value.duration.inSeconds > 0 
                                  ? _v!.value.position.inSeconds / _v!.value.duration.inSeconds : 0,
                                backgroundColor: Colors.white12,
                                color: const Color(0xFFE84393), // Pink CineFlow
                              ),
                            ),
                          ),
                          Text(_formatDur(_v!.value.duration), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Ikon Kontrol Panel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _btn(0, Icons.skip_previous),
                          _btn(1, Icons.skip_next),
                          _btn(2, Icons.subtitles),
                          _textBtn(3, "AUTO"),
                          _btn(4, Icons.aspect_ratio),
                          _btn(5, Icons.refresh),
                          _btn(6, Icons.download),
                          _btn(7, Icons.favorite_border),
                          _btn(8, Icons.list),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              
              // Ikon Pause Tengah
              if (showUI && isLoaded) Center(
                child: Icon(_v!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, 
                size: 80, color: Colors.white30),
              ),
            ],
          ),
      ),
    );
  }

  Widget _btn(int index, IconData icon) {
    bool isF = focusedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isF ? Colors.white24 : Colors.transparent,
        shape: BoxShape.circle,
        border: isF ? Border.all(color: Colors.cyan, width: 2) : null,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Widget _textBtn(int index, String text) {
    bool isF = focusedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isF ? Colors.white24 : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isF ? Colors.cyan : Colors.white30),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  String _formatDur(Duration d) => "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
}
