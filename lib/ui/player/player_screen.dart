import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/api_engine.dart';
class LiveGoPlayer extends StatefulWidget {
  final String id, source, title;
  const LiveGoPlayer({super.key, required this.id, required this.source, required this.title});
  @override State<LiveGoPlayer> createState() => _LiveGoPlayerState();
}
class _LiveGoPlayerState extends State<LiveGoPlayer> {
  VideoPlayerController? _v; bool ready = false;
  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiEngine.request("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=1&lang=id");
    if (res != null) { _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))..initialize().then((_){ setState((){ ready=true; _v!.play(); }); }); }
  }
  @override void dispose() { _v?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { return Scaffold(backgroundColor: Colors.black, body: ready ? Center(child: AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!))) : const Center(child: CircularProgressIndicator())); }
}
