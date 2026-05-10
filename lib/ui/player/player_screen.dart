import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/api_engine.dart';
import 'mobile_player.dart';
import 'tv_player.dart';

class LivegoPlayer extends StatefulWidget {
  final String id, source, title;
  const LivegoPlayer({super.key, required this.id, required this.source, required this.title});
  @override State<LivegoPlayer> createState() => _LivegoPlayerState();
}
class _LivegoPlayerState extends State<LivegoPlayer> {
  VideoPlayerController? _v; bool ready = false;
  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiEngine.request("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=1&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))..initialize().then((_){ setState((){ ready=true; _v!.play(); }); });
      _v!.addListener(() => setState(() {}));
    }
  }
  @override void dispose() { _v?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    bool isTV = MediaQuery.of(context).size.width > 900;
    return Scaffold(backgroundColor: Colors.black, body: !ready ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent)) : Stack(children: [
      Center(child: AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!))),
      isTV ? TVPlayer(v: _v!, title: widget.title) : MobilePlayer(v: _v!, title: widget.title, onToggle: ()=>setState((){ _v!.value.isPlaying?_v!.pause():_v!.play(); })),
    ]));
  }
}
