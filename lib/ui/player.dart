import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'widgets.dart';
import 'api_service.dart';

class PlayerPage extends StatefulWidget {
  final String id, source, title;
  final String? ep;
  const PlayerPage({super.key, required this.id, required this.source, required this.title, this.ep});
  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  Map? dramaData; Map? videoData;
  bool loading = true; bool showUI = true;
  int currentEp = 1; String quality = "Auto";
  Timer? _hideTimer;
  BoxFit currentFit = BoxFit.cover; // Default perlebar video

  @override void initState() { super.initState(); _init(); }

  _init() async {
    final p = await SharedPreferences.getInstance();
    currentEp = widget.ep != null ? int.parse(widget.ep!) : (p.getInt('pos_ep_${widget.id}') ?? 1);
    quality = p.getString('pref_q') ?? "Auto";
    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) { setState(() { dramaData = res['data']; }); _loadVideo(currentEp); }
  }

  _loadVideo(int ep) async {
    setState(() { loading = true; currentEp = ep; });
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=$ep&lang=id");
    if (res != null && res['success']) {
      videoData = res['data'];
      List streams = videoData!['streams'];
      var s = streams.firstWhere((e) => e['quality'].toString().contains(quality), orElse: () => streams[0]);
      if (_v != null) await _v!.dispose();
      _v = VideoPlayerController.networkUrl(Uri.parse(s['url']))..initialize().then((_) { setState(() { loading = false; _v!.play(); _startTimer(); }); });
      _v!.addListener(() { if(mounted) setState((){}); });
    }
  }

  _startTimer() { _hideTimer?.cancel(); _hideTimer = Timer(const Duration(seconds: 5), () { if(mounted) setState(() => showUI = false); }); }

  @override Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: dramaData == null ? const Center(child: CircularProgressIndicator()) : 
      GestureDetector(
        onTap: () { setState(() => showUI = !showUI); if(showUI) _startTimer(); },
        child: Column(
          children: [
            // 1. AREA VIDEO PLAYER (DI-PERLEBAR KEBAWAH: 40% Layar)
            SizedBox(
              height: screenHeight * 0.4,
              width: double.infinity,
              child: Stack(children: [
                Center(child: _v != null && _v!.value.isInitialized ? FittedBox(fit: currentFit, child: SizedBox(width: _v!.value.size.width, height: _v!.value.size.height, child: VideoPlayer(_v!))) : const CircularProgressIndicator()),
                if (showUI) _buildOverlay(),
                if (loading) Container(color: Colors.black, child: const Center(child: CircularProgressIndicator())),
              ]),
            ),
            // 2. AREA DETAIL (DI-PERKECIL)
            Expanded(child: _buildCompactDetail()),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black87, Colors.transparent, Colors.black87], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Column(children: [
        Padding(padding: const EdgeInsets.only(top: 30, left: 10), child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), Text("Eps $currentEp", style: const TextStyle(fontWeight: FontWeight.bold))])),
        const Spacer(),
        // TOMBOL PLAY TENGAH
        Icon(_v != null && _v!.value.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 60, color: Colors.white54),
        const Spacer(),
        // TOMBOL LIST EPISODE DI DALAM OVERLAY (FULLSCREEN MODE)
        Positioned(bottom: 40, right: 10, child: IconButton(icon: const Icon(Icons.format_list_bulleted, color: Colors.blueAccent), onPressed: _showEpsInOverlay)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.red))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(icon: const Icon(Icons.skip_previous, size: 20), onPressed: () { if(currentEp > 1) _loadVideo(currentEp - 1); }),
          IconButton(icon: const Icon(Icons.skip_next, size: 20), onPressed: () { if(currentEp < dramaData!['total_episodes']) _loadVideo(currentEp + 1); }),
          Text(quality, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.fullscreen, size: 20), onPressed: () => setState(() => currentFit = currentFit == BoxFit.contain ? BoxFit.cover : BoxFit.contain)),
        ]),
      ]),
    );
  }

  // TAMPILAN DETAIL YANG LEBIH KOMPAK
  Widget _buildCompactDetail() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(dramaData!['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(dramaData!['synopsis'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 2),
        const SizedBox(height: 15),
        const Text("EPISODE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        const SizedBox(height: 10),
        // GRID EPISODE DI-PERKECIL (5 Kolom)
        GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 8, crossAxisSpacing: 8), itemCount: dramaData!['total_episodes'], itemBuilder: (c, i) => TVButton(onTap: () => _loadVideo(i + 1), child: Container(decoration: BoxDecoration(color: (i + 1) == currentEp ? Colors.blueAccent.withOpacity(0.2) : Colors.white10, borderRadius: BorderRadius.circular(8), border: (i + 1) == currentEp ? Border.all(color: Colors.cyan) : null), alignment: Alignment.center, child: Text("${i + 1}", style: const TextStyle(fontSize: 13))))),
      ]),
    );
  }

  void _showEpsInOverlay() {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF161B22), builder: (c) => ListView.builder(itemCount: dramaData!['total_episodes'], itemBuilder: (ctx, i) => ListTile(title: Text("Episode ${i+1}"), trailing: (i+1) == currentEp ? const Icon(Icons.play_circle, color: Colors.blue) : null, onTap: () { Navigator.pop(c); _loadVideo(i+1); })));
  }

  @override void dispose() { _v?.dispose(); _hideTimer?.cancel(); super.dispose(); }
}
