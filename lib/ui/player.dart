import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';
import 'api_service.dart';

// ==========================================
// HALAMAN DETAIL (IDENTIK CINEFLOW)
// ==========================================
class DetailPage extends StatefulWidget {
  final String id, source;
  const DetailPage({super.key, required this.id, required this.source});
  @override State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map? d; bool loading = true;
  int lastEp = 1;

  @override void initState() { super.initState(); _init(); }
  
  _init() async {
    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    final p = await SharedPreferences.getInstance();
    if (res != null) {
      setState(() { 
        d = res['data']; 
        loading = false; 
        lastEp = p.getInt('last_ep_${widget.id}') ?? 1;
      });
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Banner Area
          Stack(children: [
            Image.network(d!['cover'], height: 260, width: double.infinity, fit: BoxFit.cover),
            Container(height: 260, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF0D1117), Colors.transparent]))),
          ]),
          
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d!['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(d!['synopsis'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5), maxLines: 3),
            const SizedBox(height: 25),
            
            // Tombol Favorit & Download Berdampingan
            Row(children: [
              Expanded(child: TVButton(onTap: (){}, borderRadius: 25, child: Container(height: 48, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(25)), child: const Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.favorite, size: 20), SizedBox(width: 8), Text("Favorit")]))))),
              const SizedBox(width: 12),
              Expanded(child: TVButton(onTap: (){}, borderRadius: 25, child: Container(height: 48, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(25)), child: const Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.file_download_outlined, size: 20), SizedBox(width: 8), Text("Download")]))))),
            ]),
          ])),

          const Padding(padding: EdgeInsets.only(left: 20, bottom: 10), child: Text("EPISODE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5))),
          
          // Grid Episode
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10),
            itemCount: d!['total_episodes'],
            itemBuilder: (c, i) => TVButton(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => PlayerPage(id: widget.id, source: widget.source, ep: (i+1).toString(), total: d!['total_episodes'], title: d!['title']))), 
              child: Container(
                decoration: BoxDecoration(
                  color: (i+1) == lastEp ? Colors.blueAccent.withOpacity(0.4) : Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                  border: (i+1) == lastEp ? Border.all(color: Colors.blueAccent) : null,
                ),
                alignment: Alignment.center, child: Text("${i+1}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }
}

// ==========================================
// PEMUTAR VIDEO (REMOTE TV OPTIMIZED)
// ==========================================
class PlayerPage extends StatefulWidget {
  final String id, source, ep, title;
  final int total;
  const PlayerPage({super.key, required this.id, required this.source, required this.ep, required this.total, required this.title});
  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  bool showMenu = false; // Menu Atas (Up)
  bool showEps = false;  // Menu Bawah (Down)
  bool isUIVisible = true;

  @override void initState() { super.initState(); _initPlayer(); }

  _init() async {
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=${widget.ep}&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) {
          setState(() { _v!.play(); });
          _saveProgress();
        });
      _v!.addListener(() {
        if (_v!.value.position == _v!.value.duration) _playNext();
        setState(() {});
      });
    }
  }

  _saveProgress() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('last_ep_${widget.id}', int.parse(widget.ep));
  }

  _playNext() {
    int cur = int.parse(widget.ep);
    if (cur < widget.total) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => PlayerPage(id: widget.id, source: widget.source, ep: (cur+1).toString(), total: widget.total, title: widget.title)));
    } else { Navigator.pop(context); }
  }

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
      _resetUITimer();
    }
  }

  _resetUITimer() {
    setState(() => isUIVisible = true);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => isUIVisible = false);
    });
  }

  @override void dispose() { _v?.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(), autofocus: true, onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          // 1. VIDEO LAYER
          Center(child: _v != null && _v!.value.isInitialized ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator(color: Colors.blueAccent)),
          
          // 2. HEADER INFO
          if (isUIVisible) Positioned(top: 30, left: 20, child: Text("${widget.title} - Episode ${widget.ep} / ${widget.total}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),

          // 3. MENU ATAS (NEXT, CC, AUTO, FAV, DL)
          if (showMenu) Positioned(top: 0, left: 0, right: 0, child: Container(
            color: Colors.black87, padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _playerIcon(Icons.skip_next, "NEXT"),
              _playerIcon(Icons.closed_caption, "CC"),
              _playerIcon(Icons.settings, "AUTO"),
              _playerIcon(Icons.aspect_ratio, "LAYAR"),
              _playerIcon(Icons.favorite_border, "FAV"),
              _playerIcon(Icons.download, "UNDUH"),
            ]),
          )),

          // 4. KONTROL TENGAH (PAUSE ICON)
          if (isUIVisible) Center(child: Icon(_v!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80, color: Colors.white54)),

          // 5. PROGRESS BAR & DURASI
          if (isUIVisible) Positioned(bottom: showEps ? 140 : 40, left: 20, right: 20, child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_formatDur(_v!.value.position), style: const TextStyle(fontSize: 12)),
              Text(_formatDur(_v!.value.duration), style: const TextStyle(fontSize: 12)),
            ]),
            const SizedBox(height: 5),
            VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.blueAccent, bufferedColor: Colors.white24, backgroundColor: Colors.white12)),
          ])),

          // 6. DAFTAR EPISODE BAWAH (HORIZONTAL)
          if (showEps) Positioned(bottom: 0, left: 0, right: 0, child: Container(
            height: 120, color: Colors.black87,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(padding: EdgeInsets.only(left: 20, top: 10), child: Text("Daftar Episode", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              Expanded(child: ListView.builder(
                scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: widget.total,
                itemBuilder: (c, i) => Container(width: 60, margin: const EdgeInsets.all(10), decoration: BoxDecoration(color: (i+1).toString() == widget.ep ? Colors.blueAccent : Colors.white10, borderRadius: BorderRadius.circular(8)), child: Center(child: Text("${i+1}"))),
              )),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _playerIcon(IconData i, String t) => Column(mainAxisSize: MainAxisSize.min, children: [Icon(i, color: Colors.white, size: 24), const SizedBox(height: 4), Text(t, style: const TextStyle(color: Colors.white, fontSize: 9))]);
  String _formatDur(Duration d) => "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  _initPlayer() => _init();
}
