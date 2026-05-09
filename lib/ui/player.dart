import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool loading = true; bool showUI = true;
  int curEp = 1; int focusedIdx = 0;
  Timer? _timer;

  @override void initState() { super.initState(); _play(1); }

  _play(int ep) async {
    setState(() { loading = true; curEp = ep; });
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=$ep&lang=id");
    if (res != null && res['success']) {
      if (_v != null) await _v!.dispose();
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) { setState(() { loading = false; _v!.play(); _startTimer(); }); });
      _v!.addListener(() => setState(() {}));
    }
  }

  _startTimer() { _timer?.cancel(); _timer = Timer(const Duration(seconds: 5), () { if(mounted) setState(() => showUI = false); }); }

  @override void dispose() { _v?.dispose(); _timer?.cancel(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Center(child: _v != null && _v!.value.isInitialized ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator()),
        if (showUI) _buildBlueUI(),
        if (loading) Container(color: Colors.black, child: const Center(child: CircularProgressIndicator())),
      ]),
    );
  }

  Widget _buildBlueUI() => Positioned(
    bottom: 30, left: 40, right: 40,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.blueAccent.withOpacity(0.5))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.pinkAccent)),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(Icons.skip_previous, color: Colors.white), SizedBox(width: 20),
          Icon(Icons.play_arrow, color: Colors.white, size: 30), SizedBox(width: 20),
          Icon(Icons.skip_next, color: Colors.white),
        ]),
      ]),
    ),
  );
}
