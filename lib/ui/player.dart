import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';
import 'widgets.dart';

class PlayerPage extends StatefulWidget {
  final String id, source, ep;
  const PlayerPage({super.key, required this.id, required this.source, this.ep = "1"});
  @override State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v;
  bool isLoaded = false;
  late int currentEpInt;

  @override
  void initState() {
    super.initState();
    currentEpInt = int.parse(widget.ep);
    _init();
  }

  _init() async {
    final p = await SharedPreferences.getInstance();
    
    // 1. LOGIKA HAPUS OTOMATIS DATA LAMA (SESUAI DISKUSI)
    // Menghapus jejak episode 1 sampai (current - 1)
    for (int i = 1; i < currentEpInt; i++) {
      String oldKey = 'pos_${widget.id}_$i';
      if (p.containsKey(oldKey)) {
        p.remove(oldKey);
        print("Sistem Livego: Cache Episode $i dihapus otomatis.");
      }
    }

    // 2. AMBIL MENIT TERAKHIR EPS SEKARANG (JANGAN DIHAPUS)
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
        });
      
      _v!.addListener(() {
        if (_v!.value.isPlaying) {
          // Simpan menit terakhir eps yang sedang ditonton
          p.setInt('pos_${widget.id}_${widget.ep}', _v!.value.position.inSeconds);
          p.setInt('last_ep_${widget.id}', currentEpInt);
        }
      });
    }
  }

  @override
  void dispose() {
    _v?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoaded 
          ? Center(child: AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!))) 
          : const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
    );
  }
}

// Halaman Detail diringkas untuk efisiensi
class DetailPage extends StatelessWidget {
  final String id, source;
  const DetailPage({super.key, required this.id, required this.source});
  @override Widget build(BuildContext context) {
    return PlayerPage(id: id, source: source);
  }
}
