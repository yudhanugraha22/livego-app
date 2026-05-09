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
  VideoPlayerController? _v; Map? d; bool ready = false; bool ui = true; Timer? _t;
  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) { d = res['data']; _load(1); }
  }
  _load(int ep) async {
    setState(() => ready = false);
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=$ep&lang=id");
    if (res != null) { _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))..initialize().then((_){ setState((){ ready=true; _v!.play(); _startT(); }); }); }
  }
  _startT() { _t?.cancel(); _t = Timer(const Duration(seconds: 5), () { if(mounted) setState(()=>ui=false); }); }
  @override void dispose() { _v?.dispose(); _t?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(backgroundColor: Colors.black, body: d == null ? const Center(child: CircularProgressIndicator()) : Column(children: [
      SizedBox(height: h * 0.45, child: GestureDetector(onTap: (){ setState(()=>ui=!ui); if(ui) _startT(); }, child: Stack(children: [
        Center(child: ready ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator()),
        if (ui && ready) Positioned(bottom: 20, left: 20, right: 20, child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))), child: Column(mainAxisSize: MainAxisSize.min, children: [
          VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.pinkAccent)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [const Icon(Icons.skip_previous), IconButton(icon: Icon(_v!.value.isPlaying?Icons.pause:Icons.play_arrow), onPressed: (){setState(()=>_v!.value.isPlaying?_v!.pause():_v!.play());}), const Icon(Icons.skip_next), IconButton(icon: const Icon(Icons.list), onPressed: _showEps)])
        ])))
      ]))),
      Expanded(child: GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 5, crossAxisSpacing: 5), itemCount: d!['total_episodes'], itemBuilder: (c, i) => TVButton(onTap: ()=>_load(i+1), child: Container(color: Colors.white10, alignment: Alignment.center, child: Text("${i+1}", style: const TextStyle(fontSize: 10))))))
    ]));
  }
  void _showEps() => showModalBottomSheet(context: context, backgroundColor: const Color(0xFF161B22), builder: (c)=>ListView.builder(itemCount: d!['total_episodes'], itemBuilder: (ctx, i)=>ListTile(title: Text("Eps ${i+1}"), onTap: (){Navigator.pop(c); _load(i+1);})) );
}
