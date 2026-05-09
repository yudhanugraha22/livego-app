import 'package:flutter/material.dart';
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
    final path = "/api/v2/detail?category_p=\$source&id=\$id&lang=id";
    final res = await ApiService.get(path);
    if (res != null) setState(() { d = res['data']; loading = false; });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF161B22), title: Text(d?['title'] ?? "Loading...")),
      body: loading ? const Center(child: CircularProgressIndicator()) : ListView(children: [
        Image.network(d!['cover'], height: 200, fit: BoxFit.cover),
        Padding(padding: const EdgeInsets.all(15), child: Text(d!['synopsis'])),
        const Padding(padding: EdgeInsets.all(15), child: Text("DAFTAR EPISODE", style: TextStyle(fontWeight: FontWeight.bold))),
        GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10), itemCount: d!['total_episodes'], itemBuilder: (c, i) => TVButton(onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (ctx) => PlayerPage(id: id, source: source, ep: (i+1).toString())));
        }, child: Container(color: Colors.white10, alignment: Alignment.center, child: Text("${i+1}"))))
      ]),
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
    final path = "/api/v2/video?category_p=\$source&id=\$id&chapterId=\$ep&lang=id";
    final res = await ApiService.get(path);
    if (res != null && res['success'] == true) {
      String videoUrl = res['data']['streams'][0]['url'];
      _v = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _v!.initialize();
      _c = ChewieController(videoPlayerController: _v!, autoPlay: true, materialProgressColors: ChewieProgressColors(playedColor: Colors.blueAccent));
      setState(() => ready = true);
    }
  }
  @override void dispose() { _v?.dispose(); _c?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { return Scaffold(backgroundColor: Colors.black, body: ready ? Chewie(controller: _c!) : const Center(child: CircularProgressIndicator())); }
}
