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
  BoxFit currentFit = BoxFit.contain;

  @override void initState() { super.initState(); _init(); }

  _init() async {
    final p = await SharedPreferences.getInstance();
    currentEp = widget.ep != null ? int.parse(widget.ep!) : (p.getInt('pos_ep_${widget.id}') ?? 1);
    quality = p.getString('pref_q') ?? "Auto";
    
    // Simpan Ke Riwayat Otomatis
    List<String> hist = p.getStringList('livego_history') ?? [];
    if (!hist.contains(widget.title)) { hist.insert(0, widget.title); p.setStringList('livego_history', hist); }

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: dramaData == null ? const Center(child: CircularProgressIndicator()) : 
      GestureDetector(
        onTap: () { setState(() => showUI = !showUI); if(showUI) _startTimer(); },
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16/9,
              child: Stack(children: [
                Center(child: _v != null && _v!.value.isInitialized ? FittedBox(fit: currentFit, child: SizedBox(width: _v!.value.size.width, height: _v!.value.size.height, child: VideoPlayer(_v!))) : const CircularProgressIndicator()),
                if (showUI) _buildOverlay(),
                if (loading) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
              ]),
            ),
            Expanded(child: _buildDetailSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black87, Colors.transparent, Colors.black87], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Column(children: [
        Padding(padding: const EdgeInsets.only(top: 30, left: 10), child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), Text("${dramaData!['title']} - Eps $currentEp", style: const TextStyle(fontWeight: FontWeight.bold))])),
        const Spacer(),
        // Kontrol Tengah: Hanya muncul saat di Tap
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: const Icon(Icons.replay_10, size: 30), onPressed: () => _v!.seekTo(_v!.value.position - const Duration(seconds: 10))),
          const SizedBox(width: 20),
          IconButton(icon: Icon(_v!.value.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 60), onPressed: () => setState(() => _v!.value.isPlaying ? _v!.pause() : _v!.play())),
          const SizedBox(width: 20),
          IconButton(icon: const Icon(Icons.forward_10, size: 30), onPressed: () => _v!.seekTo(_v!.value.position + const Duration(seconds: 10))),
        ]),
        const Spacer(),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.red))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(icon: const Icon(Icons.skip_previous), onPressed: () { if(currentEp > 1) _loadVideo(currentEp - 1); }),
          IconButton(icon: const Icon(Icons.skip_next), onPressed: () { if(currentEp < dramaData!['total_episodes']) _loadVideo(currentEp + 1); }),
          TextButton(onPressed: _showQ, child: Text(quality, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          IconButton(icon: const Icon(Icons.subtitles), onPressed: _showCC),
          IconButton(icon: const Icon(Icons.settings), onPressed: _showSet),
          IconButton(icon: const Icon(Icons.fullscreen), onPressed: () => setState(() => currentFit = currentFit == BoxFit.contain ? BoxFit.cover : BoxFit.contain)),
        ]),
      ]),
    );
  }

  void _showQ() {
    showDialog(context: context, builder: (c) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text("Kualitas"), content: Column(mainAxisSize: MainAxisSize.min, children: (videoData!['streams'] as List).map((s) => ListTile(title: Text(s['quality']), onTap: () async { quality = s['quality']; (await SharedPreferences.getInstance()).setString('pref_q', quality); Navigator.pop(c); _loadVideo(currentEp); })).toList())));
  }

  void _showCC() {
    showDialog(context: context, builder: (c) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text("Subtitle"), content: Column(mainAxisSize: MainAxisSize.min, children: (videoData!['subtitles'] as List).map((s) => ListTile(title: Text(s['language']), leading: const Icon(Icons.subtitles), onTap: () => Navigator.pop(c))).toList())));
  }

  void _showSet() {
    showDialog(context: context, builder: (c) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text("Pengaturan"), content: Column(mainAxisSize: MainAxisSize.min, children: [
      const ListTile(title: Text("Auto Next"), trailing: Icon(Icons.toggle_on, color: Colors.blue)),
      const ListTile(title: Text("Widevine DRM"), subtitle: Text("Auto")),
    ])));
  }

  Widget _buildDetailSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(dramaData!['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(dramaData!['synopsis'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 3),
        const SizedBox(height: 20),
        TVButton(onTap: _fav, borderRadius: 25, child: Container(height: 45, width: double.infinity, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(25)), child: const Center(child: Text("Favorit", style: TextStyle(fontWeight: FontWeight.bold))))),
        const SizedBox(height: 20),
        const Text("EPISODE", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10), itemCount: dramaData!['total_episodes'], itemBuilder: (c, i) => TVButton(onTap: () => _loadVideo(i + 1), child: Container(decoration: BoxDecoration(color: (i + 1) == currentEp ? Colors.blueAccent.withOpacity(0.2) : Colors.white10, borderRadius: BorderRadius.circular(10), border: (i + 1) == currentEp ? Border.all(color: Colors.cyan) : null), alignment: Alignment.center, child: Text("${i + 1}")))),
      ]),
    );
  }

  void _fav() async {
    final p = await SharedPreferences.getInstance();
    List<String> favs = p.getStringList('livego_favs') ?? [];
    if (!favs.contains(widget.title)) { favs.add(widget.title); await p.setStringList('livego_favs', favs); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ditambah ke Favorit"))); }
  }

  @override void dispose() { _v?.dispose(); _hideTimer?.cancel(); super.dispose(); }
}
