import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
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
      body: loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(child: Column(children: [
        Stack(children: [
          Image.network(d!['cover'], height: 250, width: double.infinity, fit: BoxFit.cover),
          Container(height: 250, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF0D1117), Colors.transparent]))),
        ]),
        Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d!['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(d!['synopsis'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          TVButton(onTap: (){}, borderRadius: 30, child: Container(height: 50, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(25)), child: const Center(child: Text("Favorit", style: TextStyle(fontWeight: FontWeight.bold))))),
        ])),
        const Padding(padding: EdgeInsets.only(left: 20, bottom: 10), child: Text("EPISODE", style: TextStyle(fontWeight: FontWeight.bold))),
        GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10), itemCount: d!['total_episodes'], itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => PlayerPage(id: widget.id, source: widget.source, ep: (i+1).toString()))), child: Container(color: Colors.white10, alignment: Alignment.center, child: Text("${i+1}"))))
      ])),
    );
  }
}

class PlayerPage extends StatefulWidget {
  final String id, source, ep;
  const PlayerPage({super.key, required this.id, required this.source, required this.ep});
  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v; ChewieController? _c; bool ready = false;
  @override void initState() { super.initState(); load(); }
  load() async {
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=${widget.ep}&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']));
      await _v!.initialize();
      _c = ChewieController(videoPlayerController: _v!, autoPlay: true, materialProgressColors: ChewieProgressColors(playedColor: Colors.blueAccent));
      setState(() => ready = true);
    }
  }
  @override void dispose() { _v?.dispose(); _c?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { return Scaffold(backgroundColor: Colors.black, body: ready ? Chewie(controller: _c!) : const Center(child: CircularProgressIndicator())); }
}
