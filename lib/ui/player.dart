import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'widgets.dart';
import 'api_service.dart';

class PlayerPage extends StatefulWidget {
  final String id, source;
  final String? ep;
  const PlayerPage({super.key, required this.id, required this.source, this.ep});

  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  Map? dramaData;
  Map? videoData;
  bool isLoaded = false;
  bool showUI = true;
  int currentEp = 1;
  String currentQuality = "Auto";
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    final p = await SharedPreferences.getInstance();
    currentEp = widget.ep != null ? int.parse(widget.ep!) : (p.getInt('pos_ep_${widget.id}') ?? 1);
    currentQuality = p.getString('pref_quality') ?? "Auto";

    final res = await ApiService.get("/api/v2/detail?category_p=${widget.source}&id=${widget.id}&lang=id");
    if (res != null) {
      setState(() { dramaData = res['data']; });
      _loadStream(currentEp);
    }
  }

  _loadStream(int ep) async {
    setState(() { isLoaded = false; currentEp = ep; });
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=$ep&lang=id");
    
    if (res != null && res['success']) {
      videoData = res['data'];
      List streams = videoData!['streams'];
      
      // Cari URL sesuai kualitas pilihan user, jika tidak ada pakai index 0
      var selectedStream = streams.firstWhere(
        (s) => s['quality'].toString().toLowerCase() == currentQuality.toLowerCase(),
        orElse: () => streams[0],
      );

      if (_v != null) await _v!.dispose();
      _v = VideoPlayerController.networkUrl(Uri.parse(selectedStream['url']))
        ..initialize().then((_) {
          setState(() { 
            isLoaded = true; 
            _v!.play(); 
            _startTimer();
          });
        });
      
      _v!.addListener(() {
        if (_v!.value.position >= _v!.value.duration && _v!.value.duration != Duration.zero) {
          _nextEp();
        }
        setState(() {});
      });
    }
  }

  void _nextEp() {
    if (currentEp < (dramaData?['total_episodes'] ?? 0)) {
      _loadStream(currentEp + 1);
    } else {
      Navigator.pop(context);
    }
  }

  void _startTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => showUI = false);
    });
  }

  void _showQualityDialog() {
    if (videoData == null) return;
    List streams = videoData!['streams'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Pilih Kualitas", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: streams.map((s) {
            String q = s['quality'].toString();
            return RadioListTile(
              title: Text(q, style: const TextStyle(color: Colors.white)),
              value: q,
              groupValue: currentQuality,
              activeColor: Colors.blueAccent,
              onChanged: (val) async {
                final p = await SharedPreferences.getInstance();
                await p.setString('pref_quality', val.toString());
                setState(() { currentQuality = val.toString(); });
                Navigator.pop(context);
                _loadStream(currentEp); // Muat ulang video dengan kualitas baru
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCCDialog() {
    if (videoData == null) return;
    List subs = videoData!['subtitles'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Pilih Audio / Subtitle", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: subs.map((s) => ListTile(
            title: Text(s['language'], style: const TextStyle(color: Colors.white)),
            leading: const Icon(Icons.subtitles, color: Colors.blueAccent),
            onTap: () => Navigator.pop(context),
          )).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() { _v?.dispose(); _hideTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Anti blank putih
      body: dramaData == null 
      ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
      : Stack(
          children: [
            Center(
              child: isLoaded 
              ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!))
              : const CircularProgressIndicator(color: Colors.blueAccent),
            ),

            if (showUI) ...[
              // Header Info
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.only(top: 40, left: 10, bottom: 20),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black87, Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  child: Row(children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    Expanded(child: Text("${dramaData!['title']} - Eps $currentEp", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  ]),
                ),
              ),

              // Tombol Tengah
              Center(
                child: IconButton(
                  icon: Icon(_v != null && _v!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80, color: Colors.white60),
                  onPressed: () { setState(() { _v!.value.isPlaying ? _v!.pause() : _v!.play(); }); _startTimer(); },
                ),
              ),

              // Control Bar Bawah
              Positioned(
                bottom: 20, left: 15, right: 15,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.blueAccent, bufferedColor: Colors.white24, backgroundColor: Colors.white12)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _btn(Icons.skip_previous, "PREV", () { if(currentEp > 1) _loadStream(currentEp - 1); }),
                        _btn(Icons.skip_next, "NEXT", _nextEp),
                        _btn(Icons.subtitles, "CC", _showCCDialog),
                        _btnText(currentQuality, _showQualityDialog),
                        _btn(Icons.favorite_border, "FAV", () {}),
                        _btn(Icons.format_list_bulleted, "EPS", () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
    );
  }

  Widget _btn(IconData i, String l, VoidCallback t) => Column(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: Icon(i, color: Colors.white, size: 28), onPressed: t), Text(l, style: const TextStyle(fontSize: 9, color: Colors.white70))]);
  Widget _btnText(String txt, VoidCallback t) => Column(mainAxisSize: MainAxisSize.min, children: [TextButton(onPressed: t, child: Text(txt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))), const Text("QUALITY", style: TextStyle(fontSize: 9, color: Colors.white70))]);
}

class DetailPage extends StatelessWidget {
  final String id, source;
  const DetailPage({super.key, required this.id, required this.source});
  @override Widget build(BuildContext context) { return PlayerPage(id: id, source: source); }
}
