import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../core/api_engine.dart';
import '../../core/storage.dart';
import '../shared/widgets.dart';

class LivegoPlayer extends StatefulWidget {
  final String id, source, title;
  const LivegoPlayer({super.key, required this.id, required this.source, required this.title});
  @override State<LivegoPlayer> createState() => _LivegoPlayerState();
}
class _LivegoPlayerState extends State<LivegoPlayer> {
  VideoPlayerController? _v; bool ready = false; bool ui = true; Timer? _t;
  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiEngine.request("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=1&lang=id");
    if (res != null) {
      int lastPos = await LiveStorage.read('pos_${widget.id}', 0);
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))..initialize().then((_){
        setState((){ ready=true; _v!.seekTo(Duration(seconds: lastPos)); _v!.play(); _startT(); });
      });
      _v!.addListener((){ if(_v!.value.isPlaying) LiveStorage.save('pos_${widget.id}', _v!.value.position.inSeconds); setState((){}); });
    }
  }
  _startT() { _t?.cancel(); _t = Timer(const Duration(seconds: 5), () { if(mounted) setState(()=>ui=false); }); }
  @override void dispose() { _v?.dispose(); _t?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: GestureDetector(onTap: (){ setState(()=>ui=!ui); if(ui) _startT(); }, child: Stack(children: [
      Center(child: ready ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator()),
      if (ui && ready) _buildOverlay(),
    ])));
  }
  Widget _buildOverlay() => Positioned(bottom: 30, left: 40, right: 40, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))), child: Column(mainAxisSize: MainAxisSize.min, children: [
    VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.pinkAccent)),
    const SizedBox(height: 15),
    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      const Icon(Icons.skip_previous, color: Colors.white70),
      TVButton(onTap: (){ setState(()=>_v!.value.isPlaying?_v!.pause():_v!.play()); }, child: Icon(_v!.value.isPlaying?Icons.pause:Icons.play_arrow, size: 40, color: Colors.white)),
      const Icon(Icons.skip_next, color: Colors.white70),
      const Text("AUTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
      const Icon(Icons.list, color: Colors.white70),
    ])
  ])));
}
