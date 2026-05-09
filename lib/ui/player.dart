import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';
import 'api_service.dart';

class PlayerPage extends StatefulWidget {
  final String id, source;
  const PlayerPage({super.key, required this.id, required this.source});
  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v; Map? d; bool ready = false; int curEp = 1;

  @override void initState() { super.initState(); _loadDetail(); }

  _loadDetail() async {
    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) { d = res['data']; _play(1); }
  }

  _play(int ep) async {
    setState(() => ready = false);
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=$ep&lang=id");
    if (res != null && res['success']) {
      if (_v != null) await _v!.dispose();
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) { setState(() { ready = true; _v!.play(); }); });
    }
  }

  @override void dispose() { _v?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: ready ? Stack(children: [
      Center(child: AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!))),
      Positioned(bottom: 30, left: 30, right: 30, child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(20)), child: Column(mainAxisSize: MainAxisSize.min, children: [
        VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.red)),
        const SizedBox(height: 10),
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.skip_previous), SizedBox(width: 20), Icon(Icons.pause), SizedBox(width: 20), Icon(Icons.skip_next)]),
      ])))
    ]) : const Center(child: CircularProgressIndicator()));
  }
}
