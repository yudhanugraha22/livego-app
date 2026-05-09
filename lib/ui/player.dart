import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'widgets.dart';
import 'api_service.dart';

class PlayerPage extends StatefulWidget {
  final String id, source;
  final String? ep;
  const PlayerPage({super.key, required this.id, required this.source, this.ep});

  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  Map? d;
  bool loading = true;
  bool showUI = true;
  int currentEp = 1;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    final p = await SharedPreferences.getInstance();
    // Gunakan episode yang dikirim, atau ambil dari memori terakhir nonton
    currentEp = widget.ep != null ? int.parse(widget.ep!) : (p.getInt('pos_ep_${widget.id}') ?? 1);

    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) {
      setState(() { d = res['data']; });
      _playVideo(currentEp);
    }
  }

  _playVideo(int ep) async {
    setState(() { loading = true; currentEp = ep; });
    final p = await SharedPreferences.getInstance();

    // --- LOGIKA HAPUS CACHE EPS LAMA (PATEN) ---
    for (int i = 1; i < ep; i++) {
      p.remove('pos_time_${widget.id}_$i');
    }

    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=$ep&lang=id");
    
    if (res != null && res['success']) {
      if (_v != null) await _v!.dispose();
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) {
          setState(() { 
            loading = false; 
            _v!.play(); 
            _startTimer();
          });
        });
      
      _v!.addListener(() {
        if (_v!.value.isPlaying) {
          p.setInt('pos_time_${widget.id}_$ep', _v!.value.position.inSeconds);
          p.setInt('pos_ep_${widget.id}', ep);
        }
        if (_v!.value.position >= _v!.value.duration && _v!.value.duration != Duration.zero) {
          _nextEp();
        }
      });
    }
  }

  void _nextEp() {
    if (currentEp < (d?['total_episodes'] ?? 0)) {
      _playVideo(currentEp + 1);
    } else {
      Navigator.pop(context);
    }
  }

  void _startTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => showUI = false);
    });
  }

  void _toggleUI() {
    setState(() => showUI = !showUI);
    if (showUI) _startTimer();
  }

  @override
  void dispose() {
    _v?.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTV = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          children: [
            // 1. LAYER VIDEO FULL SCREEN
            Center(
              child: _v != null && _v!.value.isInitialized
                  ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!))
                  : const CircularProgressIndicator(color: Colors.blueAccent),
            ),

            // 2. OVERLAY KONTROL (HP & TV)
            if (showUI) ...[
              // Header: Judul & Back
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.only(top: 40, left: 10),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black87, Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  child: Row(children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    Expanded(child: Text("${d?['title'] ?? ''} - Eps $currentEp", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              ),

              // Tombol Play/Pause Tengah
              Center(
                child: IconButton(
                  icon: Icon(_v != null && _v!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80, color: Colors.white60),
                  onPressed: () { setState(() { _v!.value.isPlaying ? _v!.pause() : _v!.play(); }); _startTimer(); },
                ),
              ),

              // Panel Kontrol Bawah (Identik CineFlow)
              Positioned(
                bottom: 20, left: 15, right: 15,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress Bar Biru/Pink
                    VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.blueAccent, bufferedColor: Colors.white24, backgroundColor: Colors.white12)),
                    const SizedBox(height: 15),
                    
                    // Barisan Tombol Fitur
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionIcon(Icons.skip_previous, "PREV", () { if(currentEp > 1) _playVideo(currentEp - 1); }),
                        _actionIcon(Icons.skip_next, "NEXT", _nextEp),
                        _actionIcon(Icons.subtitles, "CC", () {}),
                        _actionText("AUTO", () {}),
                        _actionIcon(Icons.favorite_border, "FAV", () {}),
                        _actionIcon(Icons.format_list_bulleted, "EPS", _showEpisodeSheet),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            if (loading) const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(IconData i, String label, VoidCallback tap) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(icon: Icon(i, color: Colors.white, size: 28), onPressed: tap),
      Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70)),
    ],
  );

  Widget _actionText(String txt, VoidCallback tap) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextButton(onPressed: tap, child: Text(txt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
      const Text("QUAL", style: TextStyle(fontSize: 9, color: Colors.white70)),
    ],
  );

  // DAFTAR EPISODE SLIDE UP
  void _showEpisodeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("PILIH EPISODE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(color: Colors.white10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10),
                itemCount: d?['total_episodes'] ?? 0,
                itemBuilder: (c, i) => InkWell(
                  onTap: () { Navigator.pop(context); _playVideo(i + 1); },
                  child: Container(
                    decoration: BoxDecoration(color: (i + 1) == currentEp ? Colors.blueAccent : Colors.white10, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Text("${i + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
