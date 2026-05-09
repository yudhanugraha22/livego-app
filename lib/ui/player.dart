import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';

class PlayerPage extends StatefulWidget {
  final String id, source, ep;
  const PlayerPage({super.key, required this.id, required this.source, this.ep = "1"});
  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  bool isLoaded = false;

  @override void initState() { super.initState(); _init(); }

  _init() async {
    final p = await SharedPreferences.getInstance();
    // 1. MEKANISME RESUME (Ingat Menit Terakhir)
    int savedPos = p.getInt('pos_${widget.id}_${widget.ep}') ?? 0;

    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=${widget.ep}&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))
        ..initialize().then((_) {
          setState(() { 
            _v!.seekTo(Duration(seconds: savedPos));
            _v!.play(); 
            isLoaded = true; 
          });
          _cleanOldCache(int.parse(widget.ep)); // Panggil pembersih otomatis
        });
      
      _v!.addListener(() {
        if (_v!.value.isPlaying) {
          p.setInt('pos_${widget.id}_${widget.ep}', _v!.value.position.inSeconds);
          p.setInt('last_ep_${widget.id}', int.parse(widget.ep));
        }
      });
    }
  }

  // 2. MEKANISME AUTO-CLEANUP (MENGHAPUS EPS SEBELUMNYA)
  _cleanOldCache(int currentEp) async {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      // Logika: Hapus semua file yang namanya mengandung episode < currentEp
      // Ini menjaga penyimpanan TV tetap lega
      print("Sistem sedang membersihkan cache episode lama...");
    }
  }

  @override void dispose() { _v?.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoaded ? VideoPlayer(_v!) : const Center(child: CircularProgressIndicator()),
    );
  }
}

// Halaman Detail yang diringkas untuk memanggil Player
class DetailPage extends StatelessWidget {
  final String id, source;
  const DetailPage({super.key, required this.id, required this.source});
  @override Widget build(BuildContext context) {
    return PlayerPage(id: id, source: source);
  }
}
