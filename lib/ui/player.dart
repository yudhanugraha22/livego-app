import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'widgets.dart';
import 'api_service.dart';

class PlayerPage extends StatefulWidget {
  final String id, source, ep;
  const PlayerPage({super.key, required this.id, required this.source, required this.ep});
  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  bool showMenu = false;
  bool showEps = false;

  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=${widget.ep}&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) => setState(() { _v!.play(); }));
    }
  }

  @override void dispose() { _v?.dispose(); super.dispose(); }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
        _v!.value.isPlaying ? _v!.pause() : _v!.play();
      } else if (key == LogicalKeyboardKey.arrowRight) {
        _v!.seekTo(_v!.value.position + const Duration(seconds: 10));
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        _v!.seekTo(_v!.value.position - const Duration(seconds: 10));
      } else if (key == LogicalKeyboardKey.arrowUp) {
        setState(() { showMenu = !showMenu; showEps = false; });
      } else if (key == LogicalKeyboardKey.arrowDown) {
        setState(() { showEps = !showEps; showMenu = false; });
      }
      setState(() {});
    }
  }

  @override Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(child: _v != null && _v!.value.isInitialized ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator()),
            if (showMenu) Positioned(top: 0, left: 0, right: 0, child: Container(color: Colors.black54, height: 80, child: const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Text("NEXT"), Text("CC"), Text("1080P"), Text("FAV")]))),
            if (showEps) Positioned(bottom: 0, left: 0, right: 0, child: Container(color: Colors.black87, height: 120, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 50, itemBuilder: (c,i)=>Container(width: 60, margin: const EdgeInsets.all(10), color: Colors.white10, child: Center(child: Text("${i+1}")))))),
          ],
        ),
      ),
    );
  }
}
