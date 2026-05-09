import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';
import 'api_service.dart';

class DetailPage extends StatefulWidget {
  final String id, source;
  const DetailPage({super.key, required this.id, required this.source});
  @override State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map? d; bool loading = true;
  int lastEp = 0;

  @override void initState() { super.initState(); _init(); }
  
  _init() async {
    // Ambil detail drama
    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) setState(() { d = res['data']; loading = false; });
    
    // Cek riwayat terakhir ditonton
    final p = await SharedPreferences.getInstance();
    setState(() { lastEp = p.getInt('last_ep_${widget.id}') ?? 1; });
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
            Text(d!['synopsis'] ?? "Tidak ada deskripsi.", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            TVButton(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => PlayerPage(id: widget.id, source: widget.source, ep: lastEp.toString(), total: d!['total_episodes']))),
              child: Container(height: 50, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)), child: Center(child: Text("LANJUT NONTON EPS $lastEp", style: const TextStyle(fontWeight: FontWeight.bold)))),
            ),
          ])),
          const Padding(padding: EdgeInsets.only(left: 20, bottom: 10), child: Text("EPISODE", style: TextStyle(fontWeight: FontWeight.bold))),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10),
            itemCount: d!['total_episodes'],
            itemBuilder: (c, i) => TVButton(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => PlayerPage(id: widget.id, source: widget.source, ep: (i+1).toString(), total: d!['total_episodes']))), 
              child: Container(color: (i+1) == lastEp ? Colors.blueAccent.withOpacity(0.3) : Colors.white10, alignment: Alignment.center, child: Text("${i+1}")),
            ),
          )
        ]),
      ),
    );
  }
}

class PlayerPage extends StatefulWidget {
  final String id, source, ep;
  final int total;
  const PlayerPage({super.key, required this.id, required this.source, required this.ep, required this.total});
  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  bool showMenu = false;

  @override void initState() { super.initState(); _init(); }
  
  _init() async {
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=${widget.ep}&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) {
          setState(() { _v!.play(); });
          _saveProgress();
        });
      
      // LOGIKA AUTO PLAY: Jika video habis, putar eps selanjutnya
      _v!.addListener(() {
        if (_v!.value.position == _v!.value.duration) {
          _playNext();
        }
      });
    }
  }

  _saveProgress() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('last_ep_${widget.id}', int.parse(widget.ep));
  }

  _playNext() {
    int current = int.parse(widget.ep);
    if (current < widget.total) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => PlayerPage(id: widget.id, source: widget.source, ep: (current + 1).toString(), total: widget.total)));
    } else {
      Navigator.pop(context);
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
        setState(() => showMenu = !showMenu);
      }
      setState(() {});
    }
  }

  @override Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(), autofocus: true, onKeyEvent: _handleKey,
      child: Scaffold(backgroundColor: Colors.black, body: Stack(children: [
        Center(child: _v != null && _v!.value.isInitialized ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator()),
        if (showMenu) Positioned(top: 0, left: 0, right: 0, child: Container(color: Colors.black54, height: 80, child: const Center(child: Text("MENU PLAYER (NEXT / CC / QUALITY)")))),
        Positioned(bottom: 20, left: 20, child: Text("EPS ${widget.ep}", style: const TextStyle(backgroundColor: Colors.black54))),
      ])),
    );
  }
}
