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
    if (res != null) { _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))..initialize().then((_){ setState((){ ready=true; _v!.play(); _startT(); }); }); _v!.addListener(()=>setState((){})); }
  }
  _startT() { _t?.cancel(); _t = Timer(const Duration(seconds: 5), () { if(mounted) setState(()=>ui=false); }); }
  @override void dispose() { _v?.dispose(); _t?.cancel(); super.dispose(); }

  void _onKey(KeyEvent e) {
    if (e is KeyDownEvent) {
      setState(()=>ui=true); _startT();
      final k = e.logicalKey;
      if (k == LogicalKeyboardKey.select || k == LogicalKeyboardKey.enter) { _v!.value.isPlaying ? _v!.pause() : _v!.play(); }
      else if (k == LogicalKeyboardKey.arrowRight) { _v!.seekTo(_v!.value.position + const Duration(seconds: 10)); }
      else if (k == LogicalKeyboardKey.arrowLeft) { _v!.seekTo(_v!.value.position - const Duration(seconds: 10)); }
    }
  }

  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return KeyboardListener(focusNode: FocusNode(), autofocus: true, onKeyEvent: _onKey, child: Scaffold(backgroundColor: Colors.black, body: Stack(children: [
      Center(child: ready ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator(color: Color(0xFF00D9FF))),
      if (ui && ready) _buildOverlay(isT),
    ])));
  }
  Widget _buildOverlay(bool isT) => Positioned(bottom: 30, left: isT?60:20, right: isT?60:20, child: Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.redAccent, backgroundColor: Colors.white12)),
      const SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [Icon(Icons.skip_previous), Icon(Icons.play_arrow, size: 40), Icon(Icons.skip_next), Text("AUTO"), Icon(Icons.list)])
    ]),
  ));
}
