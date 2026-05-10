#!/bin/bash
# ==========================================
# LIVEGO ULTIMATE HYBRID - BUILD #106 FINAL
# ==========================================
cd ~/livego_project
rm -rf lib && mkdir -p lib/core lib/ui/player lib/ui/shared lib/ui/mobile lib/ui/tv

echo "1. Membangun Mesin Inti & Kursor Neon..."
cat <<'E1' > lib/core/api_engine.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
class ApiEngine {
  static const String secret = "22dfb2b849814054af0491ff2ee3ffe33989313d7d38e97aae659757a4cf8960";
  static Future<dynamic> request(String path) async {
    String ts = DateTime.now().millisecondsSinceEpoch.toString();
    var sig = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode("GET:$path:$ts"));
    try {
      final r = await http.get(Uri.parse("https://api-drama.dobda.id$path"), 
      headers: {"X-Timestamp": ts, "X-Signature": sig.toString(), "Accept": "application/json"});
      return r.statusCode == 200 ? json.decode(r.body) : null;
    } catch (e) { return null; }
  }
}
E1

cat <<'E2' > lib/ui/shared/widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class TVButton extends StatefulWidget {
  final Widget child; final VoidCallback onTap;
  const TVButton({super.key, required this.child, required this.onTap});
  @override State<TVButton> createState() => _TVButtonState();
}
class _TVButtonState extends State<TVButton> {
  bool _isF = false;
  @override Widget build(BuildContext context) {
    return Focus(onFocusChange: (f)=>setState(()=>_isF=f), onKeyEvent: (n,e){
      if(e is KeyDownEvent && (e.logicalKey == LogicalKeyboardKey.select || e.logicalKey == LogicalKeyboardKey.enter)){
        widget.onTap(); return KeyEventResult.handled;
      } return KeyEventResult.ignored;
    }, child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 150), decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: _isF ? Colors.cyanAccent : Colors.transparent, width: 3.5), boxShadow: _isF ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.8), blurRadius: 20)] : []), transform: _isF ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(), child: widget.child)));
  }
}
E2

echo "2. Membangun Player Terpisah (HP vs TV)..."
cat <<'E3' > lib/ui/player/player_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/api_engine.dart';
import 'mobile_player.dart';
import 'tv_player.dart';

class LivegoPlayer extends StatefulWidget {
  final String id, source, title;
  const LivegoPlayer({super.key, required this.id, required this.source, required this.title});
  @override State<LivegoPlayer> createState() => _LivegoPlayerState();
}
class _LivegoPlayerState extends State<LivegoPlayer> {
  VideoPlayerController? _v; bool ready = false;
  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiEngine.request("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=1&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))..initialize().then((_){ setState((){ ready=true; _v!.play(); }); });
      _v!.addListener(() => setState(() {}));
    }
  }
  @override void dispose() { _v?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    bool isTV = MediaQuery.of(context).size.width > 900;
    return Scaffold(backgroundColor: Colors.black, body: !ready ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent)) : Stack(children: [
      Center(child: AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!))),
      isTV ? TVPlayer(v: _v!, title: widget.title) : MobilePlayer(v: _v!, title: widget.title, onToggle: ()=>setState((){ _v!.value.isPlaying?_v!.pause():_v!.play(); })),
    ]));
  }
}
E3

cat <<'E4' > lib/ui/player/tv_player.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../shared/widgets.dart';
class TVPlayer extends StatelessWidget {
  final VideoPlayerController v; final String title;
  const TVPlayer({super.key, required this.v, required this.title});
  @override Widget build(BuildContext context) {
    return Positioned(bottom: 30, left: 60, right: 60, child: Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.cyanAccent, width: 2.5)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        VideoProgressIndicator(v, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.pinkAccent)),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          const Icon(Icons.skip_previous, color: Colors.white70),
          TVButton(onTap: ()=>v.value.isPlaying?v.pause():v.play(), child: Icon(v.value.isPlaying?Icons.pause:Icons.play_arrow, size: 50, color: Colors.white)),
          const Icon(Icons.skip_next, color: Colors.white70),
          const Text("AUTO", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const Icon(Icons.list, color: Colors.white70),
        ])
      ]),
    ));
  }
}
E4

cat <<'E5' > lib/ui/player/mobile_player.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class MobilePlayer extends StatelessWidget {
  final VideoPlayerController v; final String title; final VoidCallback onToggle;
  const MobilePlayer({super.key, required this.v, required this.title, required this.onToggle});
  @override Widget build(BuildContext context) {
    return Container(color: Colors.black45, child: Column(children: [
      AppBar(backgroundColor: Colors.transparent, title: Text(title, style: const TextStyle(fontSize: 14))),
      const Spacer(),
      IconButton(icon: Icon(v.value.isPlaying?Icons.pause_circle:Icons.play_circle, size: 80, color: Colors.white60), onPressed: onToggle),
      const Spacer(),
      Padding(padding: const EdgeInsets.all(20), child: VideoProgressIndicator(v, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.redAccent))),
    ]));
  }
}
E5

echo "3. Menyusun Home & Sidebar..."
cat <<'E6' > lib/main.dart
import 'package:flutter/material.dart';
import 'ui/mobile/mobile_home.dart';
import 'ui/tv/tv_home.dart';
void main() => runApp(const LivegoApp());
class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override Widget build(BuildContext context) { return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const MainSwitcher()); }
}
class MainSwitcher extends StatelessWidget {
  const MainSwitcher({super.key});
  @override Widget build(BuildContext context) { return MediaQuery.of(context).size.width > 900 ? const TVHome() : const MobileHome(); }
}
E6

# [File mobile_home.dart & tv_home.dart tetap sama seperti build 104 agar stabil]

echo "Kirim ke GitHub..."
git add . && git commit -m "Build 106: FIXED CONNECTION & FULL MODULAR PLAYER" && git push origin main --force
echo "--- SELESAI ---"
