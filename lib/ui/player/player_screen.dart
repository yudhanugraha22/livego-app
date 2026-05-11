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
  VideoPlayerController? _v; bool ready = false; bool ui = true; Timer? _t;
  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiEngine.request("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=1&lang=id");
    String url = "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
    if (res != null && res['success'] == true) url = res['data']['streams'][0]['url'];
    _v = VideoPlayerController.networkUrl(Uri.parse(url))..initialize().then((_){ setState((){ ready=true; _v!.play(); _startT(); }); });
    _v!.addListener(()=>setState((){}));
  }
  _startT() { _t?.cancel(); _t = Timer(const Duration(seconds: 5), () { if(mounted) setState(()=>ui=false); }); }
  @override void dispose() { _v?.dispose(); _t?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(backgroundColor: Colors.black, body: Stack(children: [
      Center(child: ready ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator(color: Color(0xFF00D9FF))),
      if (ui && ready) _buildOverlay(isT),
    ]));
  }
  Widget _buildOverlay(bool isT) => Positioned(bottom: 30, left: isT?60:20, right: isT?60:20, child: Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.red, backgroundColor: Colors.white12)),
      const SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        IconButton(icon: Icon(Icons.skip_previous, color: Colors.white), onPressed: (){}),
        IconButton(icon: Icon(_v!.value.isPlaying?Icons.pause:Icons.play_arrow, size: 40, color: Colors.white), onPressed: (){ setState(()=>_v!.value.isPlaying?_v!.pause():_v!.play()); }),
        IconButton(icon: Icon(Icons.skip_next, color: Colors.white), onPressed: (){}),
        const Text("AUTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white)),
        const Icon(Icons.list, color: Colors.white),
      ])
    ]),
  ));
}
