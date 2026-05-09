import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'widgets.dart';
import 'api_service.dart';

class PlayerPage extends StatefulWidget {
  final String id, source, title;
  final String? ep;
  const PlayerPage({super.key, required this.id, required this.source, required this.title, this.ep});

  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  Map? d;
  bool loading = true;
  bool isPlaying = false;
  bool showOverlay = true;
  int currentEp = 1;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    final p = await SharedPreferences.getInstance();
    currentEp = widget.ep != null ? int.parse(widget.ep!) : (p.getInt('last_ep_${widget.id}') ?? 1);
    
    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) {
      setState(() { d = res['data']; });
      _loadVideo(currentEp);
    }
  }

  _loadVideo(int ep) async {
    setState(() { loading = true; currentEp = ep; });
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=$ep&lang=id");
    
    if (res != null && res['success']) {
      if (_v != null) await _v!.dispose();
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) {
          setState(() { 
            loading = false; 
            _v!.play(); 
            isPlaying = true;
            _startTimer();
          });
        });
      
      _v!.addListener(() {
        if (mounted) setState(() {});
        if (_v!.value.position >= _v!.value.duration && _v!.value.duration != Duration.zero) _nextEp();
      });
    }
  }

  void _nextEp() {
    if (currentEp < (d?['total_episodes'] ?? 0)) _loadVideo(currentEp + 1);
  }

  void _startTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => showOverlay = false);
    });
  }

  @override
  void dispose() { _v?.dispose(); _hideTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: d == null ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent)) : 
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. AREA VIDEO PLAYER (IDENTIK GAMBAR)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: GestureDetector(
                onTap: () { setState(() => showOverlay = !showOverlay); if(showOverlay) _startTimer(); },
                child: Stack(
                  children: [
                    Container(color: Colors.black, child: Center(child: _v != null && _v!.value.isInitialized ? VideoPlayer(_v!) : const CircularProgressIndicator())),
                    if (showOverlay) _buildCineFlowOverlay(),
                    if (loading) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: Colors.blueAccent))),
                  ],
                ),
              ),
            ),

            // 2. AREA INFO & FAVORIT (GAYA CINEFLOW)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _badge("SEDANG DIPUTAR"),
                  const SizedBox(height: 15),
                  Text(d!['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(children: [ _tag("Gratis"), const SizedBox(width: 8), _tag("Dubbing") ]),
                  const SizedBox(height: 15),
                  Text(d!['synopsis'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5), maxLines: 3),
                  const SizedBox(height: 25),
                  
                  // Tombol Favorit Lebar Gradasi Biru
                  TVButton(
                    onTap: () {}, borderRadius: 30,
                    child: Container(
                      height: 50, width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.favorite_border, color: Colors.white), SizedBox(width: 10), Text("Favorit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))])),
                    ),
                  ),

                  const SizedBox(height: 35),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text("DAFTAR EPISODE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1)),
                    Text("${d!['total_episodes']} Ep", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ]),
                  const SizedBox(height: 15),

                  // TAB FILTER (1-50, 51-...)
                  Row(children: [ _tab("1-50", true), const SizedBox(width: 10), _tab("51-75", false) ]),

                  const SizedBox(height: 20),

                  // GRID EPISODE IDENTIK GAMBAR
                  GridView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.2),
                    itemCount: d!['total_episodes'],
                    itemBuilder: (c, i) => TVButton(
                      onTap: () => _loadVideo(i + 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: (i + 1) == currentEp ? Colors.transparent : const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(15),
                          border: (i + 1) == currentEp ? Border.all(color: Colors.cyan, width: 2) : Border.all(color: Colors.white10),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          if ((i + 1) == currentEp) const Text("DIPUTAR", style: TextStyle(fontSize: 8, color: Colors.cyan, fontWeight: FontWeight.bold)),
                          const Text("EPISODE", style: TextStyle(fontSize: 7, color: Colors.grey)),
                          Text("${i + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OVERLAY PLAYER IDENTIK CINEFLOW
  Widget _buildCineFlowOverlay() {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black87, Colors.transparent, Colors.black87], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
              Expanded(child: Text("${d!['title']} - Ep $currentEp / ${d!['total_episodes']}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            ]),
          ),
          const Spacer(),
          // Kontrol Tengah
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.replay_10, size: 35), onPressed: () => _v!.seekTo(_v!.value.position - const Duration(seconds: 10))),
            const SizedBox(width: 25),
            IconButton(icon: Icon(_v!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 65), onPressed: () => setState(() => _v!.value.isPlaying ? _v!.pause() : _v!.play())),
            const SizedBox(width: 25),
            IconButton(icon: const Icon(Icons.forward_10, size: 35), onPressed: () => _v!.seekTo(_v!.value.position + const Duration(seconds: 10))),
          ]),
          const Spacer(),
          // Progress Bar Merah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(children: [
              Text(_formatDur(_v!.value.position), style: const TextStyle(fontSize: 10)),
              Expanded(child: VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.red, backgroundColor: Colors.white24))),
              Text(_formatDur(_v!.value.duration), style: const TextStyle(fontSize: 10)),
            ]),
          ),
          // Bar Icon Bawah
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [
              Icon(Icons.skip_previous, size: 22),
              Icon(Icons.skip_next, size: 22),
              Text("480P", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              Icon(Icons.subtitles_outlined, size: 22),
              Icon(Icons.music_note, size: 22),
              Icon(Icons.settings_outlined, size: 22),
              Icon(Icons.fullscreen, size: 22),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _badge(String t) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(5)), child: Text(t, style: const TextStyle(fontSize: 10, color: Colors.cyan, fontWeight: FontWeight.bold)));
  Widget _tag(String t) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(5)), child: Text(t, style: const TextStyle(fontSize: 10, color: Colors.grey)));
  Widget _tab(String t, bool a) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: a ? const Color(0xFF2563EB) : Colors.white10, borderRadius: BorderRadius.circular(15)), child: Text(t, style: TextStyle(fontSize: 12, fontWeight: a ? FontWeight.bold : FontWeight.normal)));
  String _formatDur(Duration d) => "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
}
