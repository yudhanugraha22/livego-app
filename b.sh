#!/bin/bash
# ===============================================
# LIVEGO MASTER RECOVERY - BUILD #126 (FINAL TEST)
# ===============================================
cd ~/livego_project
rm -rf lib && mkdir -p lib/core lib/providers lib/ui/mobile lib/ui/tv/widgets lib/ui/shared lib/ui/player

echo "1. Membangun Jantung API & State..."
cat <<'EOF' > lib/core/api_engine.dart
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
      headers: {"X-Timestamp": ts, "X-Signature": sig.toString(), "Accept": "application/json"}).timeout(Duration(seconds: 10));
      return r.statusCode == 200 ? json.decode(r.body) : null;
    } catch (e) { return null; }
  }
}
EOF

cat <<'EOF' > lib/providers/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_engine.dart';
final platformProvider = StateProvider<String>((ref) => "melolo");
final categoryProvider = StateProvider<String>((ref) => "Dubbing");
final dramasProvider = FutureProvider<List>((ref) async {
  final plat = ref.watch(platformProvider);
  final cat = ref.watch(categoryProvider);
  String p = (cat == "Dubbing") ? "/api/v2/search?category_p=$plat&q=sulih suara&lang=id" : "/api/v2/home?category_p=$plat&lang=id";
  final res = await ApiEngine.request(p);
  return res != null ? res['data'] : [];
});
final bannerProvider = FutureProvider<Map?>((ref) async {
  final plat = ref.watch(platformProvider);
  final res = await ApiEngine.request("/api/v2/banner?category_p=$plat&lang=id");
  return (res != null && res['data'].isNotEmpty) ? res['data'][0] : null;
});
EOF

echo "2. Membangun Player Blue Box (Video Test & Progress Merah)..."
cat <<'EOF' > lib/ui/player/player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../../core/api_engine.dart';
import '../shared/widgets.dart';

class LiveGoPlayer extends StatefulWidget {
  final String id, source, title;
  const LiveGoPlayer({super.key, required this.id, required this.source, required this.title});
  @override State<LiveGoPlayer> createState() => _LiveGoPlayerState();
}
class _LiveGoPlayerState extends State<LiveGoPlayer> {
  VideoPlayerController? _v; bool ready = false; bool ui = true; Timer? _t;
  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiEngine.request("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=1&lang=id");
    String url = "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"; // VIDEO TEST
    if (res != null && res['success'] == true) url = res['data']['streams'][0]['url'];
    _v = VideoPlayerController.networkUrl(Uri.parse(url))..initialize().then((_){ setState((){ ready=true; _v!.play(); _startT(); }); });
    _v!.addListener(()=>setState((){}));
  }
  _startT() { _t?.cancel(); _t = Timer(const Duration(seconds: 5), () { if(mounted) setState(()=>ui=false); }); }
  @override void dispose() { _v?.dispose(); _t?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(backgroundColor: Colors.black, body: GestureDetector(onTap: (){ setState(()=>ui=!ui); if(ui) _startT(); }, child: Stack(children: [
      Center(child: ready ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator(color: Color(0xFF00D9FF))),
      if (ui && ready) _buildOverlay(isT),
    ])));
  }
  Widget _buildOverlay(bool isT) => Positioned(bottom: 30, left: isT?60:20, right: isT?60:20, child: Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.red, backgroundColor: Colors.white12)),
      const SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white), onPressed: (){}),
        IconButton(icon: Icon(_v!.value.isPlaying?Icons.pause:Icons.play_arrow, size: 40, color: Colors.white), onPressed: (){ setState(()=>_v!.value.isPlaying?_v!.pause():_v!.play()); }),
        IconButton(icon: const Icon(Icons.skip_next, color: Colors.white), onPressed: (){}),
        const Text("AUTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white)),
        const Icon(Icons.list, color: Colors.white),
      ])
    ]),
  ));
}
EOF

echo "3. Membangun Beranda & Akun (Paten)..."
cat <<'EOF' > lib/ui/mobile/mobile_home.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_providers.dart';
import '../../player/player_screen.dart';
import '../shared/widgets.dart';
class MobileHome extends ConsumerWidget {
  const MobileHome({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final ds = ref.watch(dramasProvider);
    final bn = ref.watch(bannerProvider);
    final selP = ref.watch(platformProvider);
    final selC = ref.watch(categoryProvider);
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(backgroundColor: const Color(0xFF05070D), appBar: AppBar(backgroundColor: const Color(0xFF05070D), elevation: 0, title: const Text("LiveGo", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00D9FF)))), body: SingleChildScrollView(child: Column(children: [
      bn.when(data: (d)=>d==null?const SizedBox():_b(context, d, selP), loading: ()=>const SizedBox(height: 180), error: (_,__)=>const SizedBox()),
      const Divider(color: Colors.white10, indent: 15, endIndent: 15),
      _chips(ref, ["Melolo","FreeReels","FlickReels","RapidTV"], selP, true),
      _chips(ref, ["Dubbing","Populer","New","Trending"], selC, false),
      ds.when(data: (list)=>GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isT?7:4, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: list.length, itemBuilder: (c,i)=>TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: list[i]['id'], source: selP, title: list[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(list[i]['cover'], fit: BoxFit.cover)))), loading: ()=>const Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF))), error: (_,__)=>const Center(child: Text("Data Kosong", style: TextStyle(color: Colors.grey))))
    ])));
  }
  Widget _b(BuildContext ctx, Map d, String p) => Container(margin: const EdgeInsets.all(15), height: 180, decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white10)), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.network(d['cover'], fit: BoxFit.cover, width: double.infinity)), Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black, Colors.transparent]))), Padding(padding: const EdgeInsets.all(20), child: Text(d['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))]));
  Widget _chips(WidgetRef ref, List<String> l, String s, bool isP) => SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: l.length, itemBuilder: (ctx, i)=>Padding(padding: const EdgeInsets.only(right: 8), child: TVButton(radius: 20, onTap: (){ isP?ref.read(platformProvider.notifier).state=l[i].toLowerCase():ref.read(categoryProvider.notifier).state=l[i]; }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: s.toLowerCase()==l[i].toLowerCase()||s==l[i]?(isP?const Color(0xFF8B5CF6):const Color(0xFF00D9FF)):Colors.white10, borderRadius: BorderRadius.circular(20)), alignment: Alignment.center, child: Text(l[i]))))));
}
EOF

echo "4. Membangun File Inti (pubspec.yaml & main.dart)..."
cat <<'EOF' > pubspec.yaml
name: livego_streaming
version: 1.0.0+1
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  http: ^1.1.0
  shared_preferences: ^2.2.2
  video_player: ^2.8.1
  path_provider: ^2.1.1
  crypto: ^3.0.3
  cached_network_image: ^3.3.1
flutter:
  uses-material-design: true
EOF

cat <<'EOF' > lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/mobile/mobile_home.dart';
void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const ProviderScope(child: LivegoApp())); }
class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override Widget build(BuildContext context) { return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const MobileHome()); }
}
EOF

# Tambahkan Widget Shared yang tadinya error
cat <<'EOF' > lib/ui/shared/widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class TVButton extends StatefulWidget {
  final Widget child; final VoidCallback onTap; final double radius;
  const TVButton({super.key, required this.child, required this.onTap, this.radius = 18});
  @override State<TVButton> createState() => _TVButtonState();
}
class _TVButtonState extends State<TVButton> {
  bool _isF = false;
  @override Widget build(BuildContext context) {
    return Focus(onFocusChange: (f)=>setState(()=>_isF=f), onKeyEvent: (n,e){
      if(e is KeyDownEvent && (e.logicalKey == LogicalKeyboardKey.select || e.logicalKey == LogicalKeyboardKey.enter)){
        widget.onTap(); return KeyEventResult.handled;
      } return KeyEventResult.ignored;
    }, child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 150), decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.radius), border: Border.all(color: _isF ? const Color(0xFF00D9FF) : Colors.transparent, width: 3.0), boxShadow: _isF ? [BoxShadow(color: const Color(0xFF00D9FF).withOpacity(0.5), blurRadius: 15)] : []), transform: _isF ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(), child: widget.child)));
  }
}
EOF

echo "Pushing Update..."
git add . && git commit -m "Build 126: FIX ASSET ERROR + TEST VIDEO ENABLED" && git push origin main --force
