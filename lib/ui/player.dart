import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../core/api.dart';
import '../core/storage.dart';
import 'widgets.dart';

class PlayerPage extends StatefulWidget {
  final String id, source, title;
  const PlayerPage({super.key, required this.id, required this.source, required this.title});
  @override State<PlayerPage> createState() => _PlayerPageState();
}
class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v; bool ready = false; bool ui = true; Timer? _t;
  int curEp = 1;

  @override void initState() { super.initState(); _init(); }
  _init() async {
    curEp = await LiveStorage.get('last_ep_${widget.id}', 1);
    _load(curEp);
  }
  _load(int ep) async {
    setState(()=>ready=false);
    final res = await LiveApi.fetch("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=$ep&lang=id");
    if (res != null) {
      List streams = res['data']['streams'];
      // FORCE 480P LOGIC
      var s = streams.firstWhere((e) => e['quality'] == "480p", orElse: () => streams[0]);
      _v = VideoPlayerController.networkUrl(Uri.parse(s['url']))..initialize().then((_){
        setState((){ ready=true; _v!.play(); _startT(); });
      });
      _v!.addListener((){
        if(_v!.value.isPlaying) LiveStorage.saveHistory(widget.id, widget.title, ep, _v!.value.position.inSeconds);
      });
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
    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [const Icon(Icons.skip_previous), IconButton(icon: Icon(_v!.value.isPlaying?Icons.pause:Icons.play_arrow), onPressed: (){ setState(()=>_v!.value.isPlaying?_v!.pause():_v!.play()); }), const Icon(Icons.skip_next), const Text("480P", style: TextStyle(fontWeight: FontWeight.bold)), const Icon(Icons.list)])
  ])));
}
