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
  VideoPlayerController? _v; bool ready = false; bool ui = true; Timer? _t;
  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=1&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))..initialize().then((_){ setState((){ ready=true; _v!.play(); _startT(); }); });
    }
  }
  _startT() { _t?.cancel(); _t = Timer(const Duration(seconds: 5), () { if(mounted) setState(()=>ui=false); }); }
  @override void dispose() { _v?.dispose(); _t?.cancel(); super.dispose(); }

  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(backgroundColor: Colors.black, body: GestureDetector(
      onTap: (){ setState(()=>ui=!ui); if(ui) _startT(); },
      child: Stack(children: [
        Center(child: ready ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator()),
        if (ui && ready) isT ? _buildTVUI() : _buildMobileUI(),
      ]),
    ));
  }

  Widget _buildTVUI() => Positioned(bottom: 30, left: 50, right: 50, child: Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.cyanAccent, width: 2.5)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.pinkAccent)),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [Icon(Icons.skip_previous, size: 30), Icon(Icons.play_arrow, size: 50), Icon(Icons.skip_next, size: 30), Text("AUTO", style: TextStyle(fontWeight: FontWeight.bold)), Icon(Icons.list, size: 30)]),
    ]),
  ));

  Widget _buildMobileUI() => Container(color: Colors.black45, child: Column(children: [
    AppBar(backgroundColor: Colors.transparent, title: Text(widget.title)),
    const Spacer(),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(icon: const Icon(Icons.replay_10, size: 40), onPressed: (){}),
      IconButton(icon: Icon(_v!.value.isPlaying ? Icons.pause : Icons.play_arrow, size: 60), onPressed: (){ setState(()=> _v!.value.isPlaying ? _v!.pause() : _v!.play()); }),
      IconButton(icon: const Icon(Icons.forward_10, size: 40), onPressed: (){}),
    ]),
    const Spacer(),
    VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.redAccent)),
    const SizedBox(height: 20),
  ]));
}
