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
  bool ready = false; bool ui = true; Timer? _t;

  @override void initState() { super.initState(); _load(); }
  _load() async {
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=1&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_){ setState((){ ready=true; _v!.play(); _startT(); }); });
      _v!.addListener(()=>setState((){}));
    }
  }
  _startT() { _t?.cancel(); _t = Timer(const Duration(seconds: 5), () { if(mounted) setState(()=>ui=false); }); }

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: GestureDetector(
      onTap: (){ setState(()=>ui=!ui); if(ui) _startT(); },
      child: Stack(children: [
        Center(child: ready ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator()),
        if (ui && ready) _buildOverlay(),
      ]),
    ));
  }

  Widget _buildOverlay() => Stack(children: [
    Positioned(top: 40, left: 20, child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: ()=>Navigator.pop(context))),
    Positioned(bottom: 30, left: 20, right: 20, child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.pinkAccent)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(icon: const Icon(Icons.skip_previous), onPressed: (){}),
          IconButton(icon: Icon(_v!.value.isPlaying ? Icons.pause : Icons.play_arrow, size: 40), onPressed: (){ setState(()=>_v!.value.isPlaying ? _v!.pause() : _v!.play()); }),
          IconButton(icon: const Icon(Icons.skip_next), onPressed: (){}),
          const Text("AUTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          const Icon(Icons.list),
        ]),
      ]),
    )),
  ]);
  @override void dispose() { _v?.dispose(); _t?.cancel(); super.dispose(); }
}
