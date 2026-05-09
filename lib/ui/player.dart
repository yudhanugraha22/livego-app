import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'widgets.dart';
import 'api_service.dart';

class DetailPage extends StatefulWidget {
  final String id, source;
  const DetailPage({super.key, required this.id, required this.source});
  @override State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map? d; bool loading = true;
  @override void initState() { super.initState(); load(); }
  load() async {
    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) setState(() { d = res['data']; loading = false; });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.network(d!['cover'], height: 250, width: double.infinity, fit: BoxFit.cover),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d!['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(d!['synopsis'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: TVButton(onTap: (){}, child: Container(height: 45, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)), child: const Center(child: Text("Favorit"))))),
              const SizedBox(width: 10),
              Expanded(child: TVButton(onTap: (){}, child: Container(height: 45, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)), child: const Center(child: Text("Download"))))),
            ]),
          ])),
          const Padding(padding: EdgeInsets.only(left: 20, bottom: 10), child: Text("EPISODE", style: TextStyle(fontWeight: FontWeight.bold))),
          GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10), itemCount: d!['total_episodes'], itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => PlayerPage(id: widget.id, source: widget.source, ep: (i+1).toString()))), child: Container(color: Colors.white10, alignment: Alignment.center, child: Text("${i+1}"))))
        ]),
      ),
    );
  }
}

class PlayerPage extends StatefulWidget {
  final String id, source, ep;
  const PlayerPage({super.key, required this.id, required this.source, required this.ep});
  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  bool showMenu = false; bool showEps = false;

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
      final k = event.logicalKey;
      if (k == LogicalKeyboardKey.select || k == LogicalKeyboardKey.enter) {
        _v!.value.isPlaying ? _v!.pause() : _v!.play();
      } else if (k == LogicalKeyboardKey.arrowRight) {
        _v!.seekTo(_v!.value.position + const Duration(seconds: 10));
      } else if (k == LogicalKeyboardKey.arrowLeft) {
        _v!.seekTo(_v!.value.position - const Duration(seconds: 10));
      } else if (k == LogicalKeyboardKey.arrowUp) {
        setState(() { showMenu = !showMenu; showEps = false; });
      } else if (k == LogicalKeyboardKey.arrowDown) {
        setState(() { showEps = !showEps; showMenu = false; });
      }
      setState(() {});
    }
  }

  @override Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(), autofocus: true, onKeyEvent: _handleKey,
      child: Scaffold(backgroundColor: Colors.black, body: Stack(children: [
        Center(child: _v != null && _v!.value.isInitialized ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator()),
        if (showMenu) Positioned(top: 0, left: 0, right: 0, child: Container(color: Colors.black54, height: 80, child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_btn(Icons.skip_next, "NEXT"), _btn(Icons.subtitles, "CC"), _btn(Icons.hd, "1080P"), _btn(Icons.favorite, "FAV")]))),
        if (showEps) Positioned(bottom: 0, left: 0, right: 0, child: Container(color: Colors.black87, height: 100, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 50, itemBuilder: (c,i)=>_epCard(i+1)))),
      ])),
    );
  }
  Widget _btn(IconData i, String t) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, color: Colors.white, size: 20), Text(t, style: const TextStyle(fontSize: 9, color: Colors.white))]);
  Widget _epCard(int n) => Container(width: 50, margin: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(5)), child: Center(child: Text("$n")));
}
