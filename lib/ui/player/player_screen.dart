import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../../core/api_engine.dart';
import '../shared/widgets.dart';
import 'player_modals.dart';

class LiveGoPlayer extends StatefulWidget {
  final String id, source, title;
  const LiveGoPlayer({super.key, required this.id, required this.source, required this.title});
  @override State<LiveGoPlayer> createState() => _LiveGoPlayerState();
}

class _LiveGoPlayerState extends State<LiveGoPlayer> {
  VideoPlayerController? _v;
  bool ready = false; bool ui = true; Timer? _t;
  String q = "Auto", au = "id-ID Stereo", sub = "Indonesia";
  int fIdx = 1; // Fokus tombol tengah secara default

  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiEngine.request("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=1&lang=id");
    String url = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"; // Fallback Test
    if (res != null) url = res['data']['streams'][0]['url'];
    _v = VideoPlayerController.networkUrl(Uri.parse(url))..initialize().then((_){ setState((){ ready=true; _v!.play(); _startT(); }); });
    _v!.addListener(()=>setState((){}));
  }
  _startT() { _t?.cancel(); _t = Timer(const Duration(seconds: 5), () { if(mounted) setState(()=>ui=false); }); }

  void _onKey(KeyEvent e) {
    if (e is KeyDownEvent) {
      setState(()=>ui=true); _startT();
      final k = e.logicalKey;
      if (k == LogicalKeyboardKey.select || k == LogicalKeyboardKey.enter) {
        if(fIdx == 1) _v!.value.isPlaying ? _v!.pause() : _v!.play();
      }
      else if (k == LogicalKeyboardKey.arrowRight) { if(ui && fIdx < 6) setState(()=>fIdx++); else _v!.seekTo(_v!.value.position + const Duration(seconds: 10)); }
      else if (k == LogicalKeyboardKey.arrowLeft) { if(ui && fIdx > 0) setState(()=>fIdx--); else _v!.seekTo(_v!.value.position - const Duration(seconds: 10)); }
    }
  }

  @override void dispose() { _v?.dispose(); _t?.cancel(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return KeyboardListener(focusNode: FocusNode(), autofocus: true, onKeyEvent: _onKey, child: Scaffold(backgroundColor: Colors.black, body: Stack(children: [
      Center(child: ready ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator(color: Color(0xFF00D9FF))),
      if (ui && ready) _buildOverlay(),
    ])));
  }

  Widget _buildOverlay() {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Stack(children: [
      // TOP BAR
      Positioned(top: 40, left: 20, child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: ()=>Navigator.pop(context)), Text("${widget.title} - Ep 1", style: const TextStyle(fontWeight: FontWeight.bold))])),
      
      // PAUSE ICON CENTER
      Center(child: Icon(_v!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80, color: Colors.white24)),

      // BOTTOM BLUE PANEL (IDENTIK CINEFLOW)
      Positioned(bottom: 30, left: isT?60:20, right: isT?60:20, child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.2))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Text(_dur(_v!.value.position), style: const TextStyle(fontSize: 10)),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.red, backgroundColor: Colors.white12)))),
            Text(_dur(_v!.value.duration), style: const TextStyle(fontSize: 10)),
          ]),
          const SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _icon(0, Icons.skip_previous),
            _icon(1, _v!.value.isPlaying ? Icons.pause : Icons.play_arrow),
            _icon(2, Icons.skip_next),
            _textBtn(3, q, () => PlayerModals.showQuality(context, q, (v)=>setState(()=>q=v))),
            _icon(4, Icons.subtitles, () => PlayerModals.showSubtitle(context, sub, (v)=>setState(()=>sub=v))),
            _icon(5, Icons.music_note, () => PlayerModals.showAudio(context, au, (v)=>setState(()=>au=v))),
            _icon(6, Icons.settings),
          ])
        ]),
      )),
    ]);
  }

  Widget _icon(int i, IconData ico, [VoidCallback? c]) => TVButton(radius: 50, onTap: c??(){}, child: Icon(ico, color: fIdx == i ? const Color(0xFF00D9FF) : Colors.white, size: i == 1 ? 35 : 22));
  Widget _textBtn(int i, String t, VoidCallback c) => TVButton(radius: 15, onTap: c, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Text(t, style: TextStyle(color: fIdx == i ? const Color(0xFF00D9FF) : Colors.white, fontSize: 10, fontWeight: FontWeight.bold))));
  String _dur(Duration d) => "${d.inMinutes.toString().padLeft(2,'0')}:${(d.inSeconds%60).toString().padLeft(2,'0')}";
}
