import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'widgets.dart';
import 'api_service.dart';

class PlayerPage extends StatefulWidget {
  final String id, source, title;
  const PlayerPage({super.key, required this.id, required this.source, required this.title});
  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  Map? d; bool loading = true; bool showUI = true;
  Timer? _timer; BoxFit currentFit = BoxFit.contain;

  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) { d = res['data']; _load(1); }
  }
  _load(int ep) async {
    setState(() => loading = true);
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=$ep&lang=id");
    if (res != null && res['success']) {
      if (_v != null) await _v!.dispose();
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) { setState(() { loading = false; _v!.play(); _startT(); }); });
      _v!.addListener(() { if(mounted) setState((){}); });
    }
  }
  _startT() { _timer?.cancel(); _timer = Timer(const Duration(seconds: 5), () { if(mounted) setState(() => showUI = false); }); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Kunci hitam anti-blink
      body: d == null ? const Center(child: CircularProgressIndicator()) : Column(children: [
        AspectRatio(
          aspectRatio: 16/9,
          child: GestureDetector(
            onTap: () { setState(() => showUI = !showUI); if(showUI) _startT(); },
            child: Stack(children: [
              Center(child: _v != null && _v!.value.isInitialized ? FittedBox(fit: currentFit, child: SizedBox(width: _v!.value.size.width, height: _v!.value.size.height, child: VideoPlayer(_v!))) : const CircularProgressIndicator()),
              if (showUI) _buildOverlay(),
              if (loading) Container(color: Colors.black, child: const Center(child: CircularProgressIndicator())),
            ]),
          ),
        ),
        Expanded(child: _buildEps()),
      ]),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black87, Colors.transparent, Colors.black87], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Column(children: [
        Padding(padding: const EdgeInsets.only(top: 30, left: 10), child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), Text(d!['title'], style: const TextStyle(fontWeight: FontWeight.bold))])),
        const Spacer(),
        IconButton(icon: Icon(_v!.value.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 60, color: Colors.white), onPressed: () => setState(()=> _v!.value.isPlaying ? _v!.pause() : _v!.play())),
        const Spacer(),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.red))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(icon: const Icon(Icons.skip_previous), onPressed: (){}),
          IconButton(icon: const Icon(Icons.skip_next), onPressed: (){}),
          const Text("AUTO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.format_list_bulleted), onPressed: (){}),
          IconButton(icon: const Icon(Icons.fullscreen), onPressed: () => setState(() => currentFit = currentFit == BoxFit.contain ? BoxFit.cover : BoxFit.contain)),
        ]),
      ]),
    );
  }

  Widget _buildEps() => GridView.builder(padding: const EdgeInsets.all(15), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 8, crossAxisSpacing: 8), itemCount: d!['total_episodes'], itemBuilder: (c, i) => TVButton(onTap: () => _load(i+1), child: Container(decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: Text("${i+1}"))));
  @override void dispose() { _v?.dispose(); _timer?.cancel(); super.dispose(); }
}
