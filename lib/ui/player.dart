import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'api_service.dart';

class PlayerPage extends StatefulWidget {
  final String id, source, ep;
  const PlayerPage({super.key, required this.id, required this.source, this.ep = "1"});
  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  Map? drama;
  bool isLoaded = false;
  bool showUI = true;
  int focusedIdx = 0;
  Timer? _timer;

  @override
  void initState() { super.initState(); _init(); }

  _init() async {
    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) {
      setState(() { drama = res['data']; });
      _loadVideo(widget.ep);
    }
  }

  _loadVideo(String ep) async {
    setState(() => isLoaded = false);
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=$ep&lang=id");
    if (res != null && res['success']) {
      if (_v != null) await _v!.dispose();
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) {
          setState(() { isLoaded = true; _v!.play(); });
          _startTimer();
        });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () { if(mounted) setState(() => showUI = false); });
  }

  @override
  void dispose() { _v?.dispose(); _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    bool isTV = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: drama == null ? const Center(child: CircularProgressIndicator()) : 
      GestureDetector(
        onTap: () { setState(() => showUI = !showUI); if(showUI) _startTimer(); },
        child: Stack(
          children: [
            // 1. VIDEO LAYER
            Center(child: isLoaded ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator()),

            // 2. TAMPILAN CONTROL (TV VS HP)
            if (showUI) isTV ? _buildTVUI() : _buildMobileUI(),
          ],
        ),
      ),
    );
  }

  // UI KHUSUS TV (SESUAI FOTO)
  Widget _buildTVUI() {
    return Positioned(
      bottom: 30, left: 50, right: 50,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2A4F).withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.pinkAccent)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _icon(0, Icons.skip_previous),
                _icon(1, Icons.skip_next),
                _icon(2, Icons.subtitles),
                const Text(" AUTO ", style: TextStyle(fontWeight: FontWeight.bold)),
                _icon(3, Icons.aspect_ratio),
                _icon(4, Icons.favorite_border),
                _icon(5, Icons.list),
              ],
            )
          ],
        ),
      ),
    );
  }

  // UI KHUSUS HP (MODERN & SIMPLE)
  Widget _buildMobileUI() {
    return Container(
      color: Colors.black45,
      child: Column(
        children: [
          AppBar(backgroundColor: Colors.transparent, title: Text(drama!['title'], style: const TextStyle(fontSize: 14))),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(Icons.replay_10, size: 40), onPressed: () => _v!.seekTo(_v!.value.position - const Duration(seconds: 10))),
              IconButton(icon: Icon(_v!.value.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 70), onPressed: () => setState(() => _v!.value.isPlaying ? _v!.pause() : _v!.play())),
              IconButton(icon: const Icon(Icons.forward_10, size: 40), onPressed: () => _v!.seekTo(_v!.value.position + const Duration(seconds: 10))),
            ],
          ),
          const Spacer(),
          VideoProgressIndicator(_v!, allowScrubbing: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _icon(int idx, IconData i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Icon(i, color: Colors.white));
}
