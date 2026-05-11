import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../../core/api_engine.dart';
import '../shared/widgets.dart';

class LiveGoPlayer extends StatefulWidget {
  final String id, source, title;
  const LiveGoPlayer({super.key, required this.id, required this.source, required this.title});
  @override State<LiveGoPlayer> createState() => _LiveGoPlayerState();
}

class _LiveGoPlayerState extends State<LiveGoPlayer> {
  VideoPlayerController? _v;
  bool ready = false;
  bool showOverlay = true;
  bool showEps = false;
  int totalEps = 1;
  int currentEp = 1;
  Timer? _timer;

  @override void initState() { super.initState(); _loadDetail(); }

  _loadDetail() async {
    final res = await ApiEngine.request("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) {
      totalEps = res['data']['total_episodes'] ?? 1;
      _initPlayer(1);
    }
  }

  _initPlayer(int ep) async {
    setState(() { ready = false; currentEp = ep; showEps = false; });
    final res = await ApiEngine.request("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=$ep&lang=id");
    if (res != null) {
      if (_v != null) await _v!.dispose();
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_){
          setState((){ ready = true; _v!.play(); _startTimer(); });
        });
      _v!.addListener(() => setState(() {}));
    }
  }

  _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () { if(mounted) setState(() => showOverlay = false); });
  }

  // ==========================================
  // LOGIKA REMOTE TV (ATAS, BAWAH, KIRI, KANAN, OK)
  // ==========================================
  void _onKey(KeyEvent e) {
    if (e is KeyDownEvent) {
      setState(() => showOverlay = true);
      _startTimer();
      final k = e.logicalKey;

      if (k == LogicalKeyboardKey.select || k == LogicalKeyboardKey.enter) {
        _v!.value.isPlaying ? _v!.pause() : _v!.play();
      } else if (k == LogicalKeyboardKey.arrowRight) {
        _v!.seekTo(_v!.value.position + const Duration(seconds: 10));
      } else if (k == LogicalKeyboardKey.arrowLeft) {
        _v!.seekTo(_v!.value.position - const Duration(seconds: 10));
      } else if (k == LogicalKeyboardKey.arrowDown) {
        setState(() { showEps = !showEps; if(showEps) showOverlay = true; });
      } else if (k == LogicalKeyboardKey.arrowUp) {
        // Logika munculkan menu settings/CC (Placeholder)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menu Fitur Muncul"), duration: Duration(seconds: 1)));
      }
    }
  }

  @override void dispose() { _v?.dispose(); _timer?.cancel(); super.dispose(); }

  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: !ready ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF))) : Stack(
          children: [
            // 1. VIDEO UTAMA
            Center(child: AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!))),
            
            // 2. OVERLAY KONTROL (BLUE PANEL)
            if (showOverlay) _buildBluePanel(isT),

            // 3. DAFTAR EPISODE (MUNCUL JIKA TEKAN BAWAH)
            if (showEps) _buildEpisodeList(),

            // 4. JUDUL POJOK ATAS
            if (showOverlay) Positioned(top: 40, left: 20, child: Text("${widget.title} - Eps $currentEp", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Widget _buildBluePanel(bool isT) => Positioned(
    bottom: showEps ? 140 : 30, left: isT?60:20, right: isT?60:20,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.redAccent, backgroundColor: Colors.white12)),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          const Icon(Icons.skip_previous, color: Colors.white70),
          Icon(_v!.value.isPlaying ? Icons.pause : Icons.play_arrow, size: 40, color: Colors.white),
          const Icon(Icons.skip_next, color: Colors.white70),
          const Text("AUTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          const Icon(Icons.subtitles, color: Colors.white70),
          const Icon(Icons.settings, color: Colors.white70),
        ]),
      ]),
    ),
  );

  Widget _buildEpisodeList() => Positioned(
    bottom: 20, left: 0, right: 0,
    child: Container(
      height: 100,
      color: Colors.black87,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: totalEps,
        itemBuilder: (ctx, i) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: TVButton(
            onTap: () => _initPlayer(i + 1),
            child: Container(
              width: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (i + 1) == currentEp ? const Color(0xFF00D9FF) : Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text("${i + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    ),
  );
}
