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
  int focusedIndex = 0; // Untuk navigasi remote TV
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    final p = await SharedPreferences.getInstance();
    currentEp = widget.ep != null ? int.parse(widget.ep!) : (p.getInt('pos_ep_${widget.id}') ?? 1);
    
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
      if (mounted) setState(() => showUI = false);
    });
  }

  void _handleRemote(KeyEvent event) {
    if (event is KeyDownEvent) {
      setState(() => showUI = true);
      _startTimer();
      final k = event.logicalKey;
      if (k == LogicalKeyboardKey.select || k == LogicalKeyboardKey.enter) {
        if (!showUI) setState(() => showUI = true);
        else _onTVAction(focusedIndex);
      } else if (k == LogicalKeyboardKey.arrowRight) {
        if (showUI) setState(() { if(focusedIndex < 8) focusedIndex++; });
        else _v!.seekTo(_v!.value.position + const Duration(seconds: 10));
      } else if (k == LogicalKeyboardKey.arrowLeft) {
        if (showUI) setState(() { if(focusedIndex > 0) focusedIndex--; });
        else _v!.seekTo(_v!.value.position - const Duration(seconds: 10));
      }
    }
  }

  void _onTVAction(int index) {
    if (index == 0 && currentEp > 1) _loadVideo(currentEp - 1);
    if (index == 1 && currentEp < (d?['total_episodes'] ?? 0)) _loadVideo(currentEp + 1);
  }

  @override
  void dispose() { _v?.dispose(); _hideTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    bool isTV = MediaQuery.of(context).size.width > 900;

    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _handleRemote,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: d == null 
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : isTV ? _buildTVLayout() : _buildMobileLayout(),
      ),
    );
  }

  // ==========================================
  // TAMPILAN HP (VIDEO TOP + DETAIL BOTTOM)
  // ==========================================
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Area
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                _v != null && _v!.value.isInitialized ? VideoPlayer(_v!) : const Center(child: CircularProgressIndicator()),
                if (showUI) _buildMobileOverlay(),
                if (loading) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
              ],
            ),
          ),
          // Detail Area
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d!['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(d!['synopsis'] ?? "", maxLines: 3, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              TVButton(onTap: (){}, borderRadius: 30, child: Container(height: 50, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(30)), child: const Center(child: Text("Favorit", style: TextStyle(fontWeight: FontWeight.bold))))),
              const SizedBox(height: 20),
              const Text("EPISODE", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10),
                itemCount: d!['total_episodes'],
                itemBuilder: (c, i) => TVButton(onTap: () => _loadVideo(i + 1), child: Container(decoration: BoxDecoration(color: (i+1)==currentEp ? Colors.blueAccent : Colors.white10, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Text("${i+1}"))),
              )
            ]),
          )
        ],
      ),
    );
  }

  // ==========================================
  // TAMPILAN TV (FULL SCREEN + BLUE PANEL)
  // ==========================================
  Widget _buildTVLayout() {
    return Stack(
      children: [
        Center(child: _v != null && _v!.value.isInitialized ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator()),
        if (showUI) ...[
          // Header Info TV
          Positioned(top: 40, left: 40, child: Text("${d!['title']} - Ep $currentEp", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          // Blue Panel Control (Identik CineFlow TV)
          Positioned(
            bottom: 40, left: 60, right: 60,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.blueAccent.withOpacity(0.5))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Text(_formatDur(_v!.value.position)),
                  Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: LinearProgressIndicator(value: _v!.value.duration.inSeconds > 0 ? _v!.value.position.inSeconds / _v!.value.duration.inSeconds : 0, color: Colors.red))),
                  Text(_formatDur(_v!.value.duration)),
                ]),
                const SizedBox(height: 15),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _tvIcon(0, Icons.skip_previous), _tvIcon(1, Icons.skip_next), _tvIcon(2, Icons.subtitles),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("AUTO", style: TextStyle(fontWeight: FontWeight.bold))),
                  _tvIcon(3, Icons.aspect_ratio), _tvIcon(4, Icons.refresh), _tvIcon(5, Icons.download), _tvIcon(6, Icons.favorite_border), _tvIcon(7, Icons.list),
                ])
              ]),
            ),
          )
        ],
        if (loading) const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      ],
    );
  }

  Widget _buildMobileOverlay() {
    return Container(
      color: Colors.black45,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: const Icon(Icons.replay_10, size: 40), onPressed: () => _v!.seekTo(_v!.value.position - const Duration(seconds: 10))),
          IconButton(icon: Icon(_v!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 70), onPressed: () => setState(() => _v!.value.isPlaying ? _v!.pause() : _v!.play())),
          IconButton(icon: const Icon(Icons.forward_10, size: 40), onPressed: () => _v!.seekTo(_v!.value.position + const Duration(seconds: 10))),
        ]),
      ]),
    );
  }

  Widget _tvIcon(int idx, IconData icon) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 5),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: focusedIndex == idx ? Colors.white24 : Colors.transparent, shape: BoxShape.circle, border: focusedIndex == idx ? Border.all(color: Colors.cyan) : null),
    child: Icon(icon, color: Colors.white, size: 20),
  );

  String _formatDur(Duration d) => "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
}
