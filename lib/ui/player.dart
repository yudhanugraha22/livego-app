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
  bool showUI = true; bool loading = true;
  @override void initState() { super.initState(); _init(); }

  _init() async {
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=1&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) { setState(() { loading = false; _v!.play(); }); });
      _v!.addListener(() => setState(() {}));
    }
  }

  @override Widget build(BuildContext context) {
    bool isTV = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: Colors.black,
      body: loading ? const Center(child: CircularProgressIndicator()) : Stack(children: [
        Center(child: AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!))),
        if (showUI) isTV ? _tvOverlay() : _mobileOverlay(),
      ]),
    );
  }

  Widget _tvOverlay() => Positioned(
    bottom: 30, left: 50, right: 50,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.blueAccent.withOpacity(0.5))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.pinkAccent)),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(Icons.skip_previous, color: Colors.white), SizedBox(width: 20),
          Icon(Icons.play_arrow, size: 40), SizedBox(width: 20),
          Icon(Icons.skip_next, color: Colors.white),
        ]),
      ]),
    ),
  );

  Widget _mobileOverlay() => Container(color: Colors.black45, child: Column(children: [
    AppBar(backgroundColor: Colors.transparent, title: Text(widget.title)),
    const Spacer(),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(icon: const Icon(Icons.replay_10, size: 40), onPressed: (){}),
      IconButton(icon: Icon(_v!.value.isPlaying ? Icons.pause : Icons.play_arrow, size: 60), onPressed: (){ setState(()=> _v!.value.isPlaying ? _v!.pause() : _v!.play()); }),
      IconButton(icon: const Icon(Icons.forward_10, size: 40), onPressed: (){}),
    ]),
    const Spacer(),
    VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.red)),
  ]));

  @override void dispose() { _v?.dispose(); super.dispose(); }
}
