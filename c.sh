#!/bin/bash
# ===============================================
# LIVEGO MASTER FINAL - BUILD #125 (ONE-SHOT)
# HP (Portrait Direct) & TV (Sidebar + Blue Player)
# ===============================================
cd ~/livego_project
rm -rf lib && mkdir -p lib/core lib/providers lib/ui/mobile lib/ui/tv/widgets lib/ui/shared lib/ui/player

echo "1. Membangun Jantung Data & Penyimpanan (Core)..."
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
      headers: {"X-Timestamp": ts, "X-Signature": sig.toString(), "Accept": "application/json"});
      return r.statusCode == 200 ? json.decode(r.body) : null;
    } catch (e) { return null; }
  }
}
EOF
cat <<'EOF' > lib/core/storage_engine.dart
import 'package:shared_preferences/shared_preferences.dart';
class StorageEngine {
  static Future<void> save(String k, dynamic v) async {
    final p = await SharedPreferences.getInstance();
    if (v is String) p.setString(k, v); else if (v is bool) p.setBool(k, v); else if (v is int) p.setInt(k, v);
  }
  static Future<dynamic> read(String k, dynamic def) async {
    final p = await SharedPreferences.getInstance();
    return p.get(k) ?? def;
  }
}
EOF

echo "2. Membangun State Management (Riverpod)..."
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

echo "3. Membangun Kursor TV Neon & Sidebar..."
cat <<'EOF' > lib/ui/shared/widgets.dart
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
    }, child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 150), decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: _isF ? const Color(0xFF00D9FF) : Colors.transparent, width: 3.0), boxShadow: _isF ? [BoxShadow(color: const Color(0xFF00D9FF).withOpacity(0.5), blurRadius: 15)] : []), transform: _isF ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(), child: widget.child)));
  }
}
EOF
cat <<'EOF' > lib/ui/tv/widgets/tv_sidebar.dart
import 'package:flutter/material.dart';
import '../../shared/widgets.dart';
class TVSidebar extends StatelessWidget {
  final int sel; final Function(int) onSel;
  const TVSidebar({super.key, required this.sel, required this.onSel});
  @override Widget build(BuildContext context) {
    return Container(width: 80, color: const Color(0xFF161B22), child: Column(children: [
      const SizedBox(height: 30),
      TVButton(onTap:(){}, child: Container(height: 45, width: 45, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.purple, Colors.blue])), child: const Icon(Icons.play_arrow, color: Colors.white))),
      const Spacer(),
      _i(0, Icons.home_filled), _i(1, Icons.download), _i(2, Icons.history), _i(3, Icons.favorite), _i(4, Icons.person), _i(5, Icons.search),
      const SizedBox(height: 30),
    ]));
  }
  Widget _i(int idx, IconData ico) => Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: TVButton(onTap: ()=>onSel(idx), child: Icon(ico, color: sel == idx ? Colors.blueAccent : Colors.white24)));
}
EOF

echo "4. Membangun Player Premium (RED Bar + Blue Panel + Remote)..."
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
  VideoPlayerController? _v; bool ready = false; bool ui = true; Timer? _t; bool showEps = false;
  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiEngine.request("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=1&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))..initialize().then((_){ setState((){ ready=true; _v!.play(); _startT(); }); });
      _v!.addListener(()=>setState((){}));
    }
  }
  _startT() { _t?.cancel(); _t = Timer(const Duration(seconds: 5), () { if(mounted) setState(()=>ui=false); }); }
  @override void dispose() { _v?.dispose(); _t?.cancel(); super.dispose(); }

  void _onKey(KeyEvent e) {
    if (e is KeyDownEvent) {
      setState(()=>ui=true); _startT();
      final k = e.logicalKey;
      if (k == LogicalKeyboardKey.select || k == LogicalKeyboardKey.enter) { _v!.value.isPlaying ? _v!.pause() : _v!.play(); }
      else if (k == LogicalKeyboardKey.arrowRight) { _v!.seekTo(_v!.value.position + const Duration(seconds: 10)); }
      else if (k == LogicalKeyboardKey.arrowLeft) { _v!.seekTo(_v!.value.position - const Duration(seconds: 10)); }
      else if (k == LogicalKeyboardKey.arrowDown) { setState(()=>showEps = !showEps); }
      else if (k == LogicalKeyboardKey.arrowUp) { setState(()=>ui = true); }
    }
  }

  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return KeyboardListener(focusNode: FocusNode(), autofocus: true, onKeyEvent: _onKey, child: Scaffold(backgroundColor: Colors.black, body: Stack(children: [
      Center(child: ready ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator(color: Color(0xFF00D9FF))),
      if (ui && ready) _buildOverlay(isT),
      if (showEps) Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 100, color: Colors.black87, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 50, itemBuilder: (c,i)=>_ep(i+1)))),
    ])));
  }
  Widget _ep(int n) => Container(width: 50, margin: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(5)), child: Center(child: Text("$n")));
  Widget _buildOverlay(bool isT) => Positioned(bottom: 30, left: isT?60:20, right: isT?60:20, child: Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.red, backgroundColor: Colors.white12)),
      const SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [Icon(Icons.skip_previous), Icon(Icons.play_arrow, size: 40), Icon(Icons.skip_next), Text("AUTO"), Icon(Icons.list)])
    ]),
  ));
}
EOF

echo "5. Membangun Beranda HP & TV (Paten)..."
cat <<'EOF' > lib/ui/tv/tv_home.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_providers.dart';
import '../../shared/widgets.dart';
import 'widgets/tv_sidebar.dart';
import '../player/player_screen.dart';
class TVHome extends ConsumerStatefulWidget {
  const TVHome({super.key});
  @override ConsumerState<TVHome> createState() => _TVHomeState();
}
class _TVHomeState extends ConsumerState<TVHome> {
  int sideIdx = 0;
  @override Widget build(BuildContext context) {
    final dramas = ref.watch(dramasProvider);
    final banner = ref.watch(bannerProvider);
    final selP = ref.watch(platformProvider);
    return Scaffold(backgroundColor: const Color(0xFF0D1117), body: Row(children: [
      TVSidebar(sel: sideIdx, onSel: (i)=>setState(()=>sideIdx=i)),
      Expanded(child: SingleChildScrollView(child: Column(children: [
        banner.when(data: (d)=>d==null?const SizedBox():_b(d, selP), loading: ()=>const SizedBox(height: 200), error: (_,__)=>const SizedBox()),
        _chips(ref, selP),
        dramas.when(data: (list)=>GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.65, mainAxisSpacing: 15, crossAxisSpacing: 15), itemCount: list.length, itemBuilder: (c, i) => TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: list[i]['id'], source: selP, title: list[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(list[i]['cover'], fit: BoxFit.cover)))), loading: ()=>const Center(child: CircularProgressIndicator()), error: (e,s)=>const SizedBox())
      ])))
    ]));
  }
  Widget _b(Map d, String p) => Container(margin: const EdgeInsets.all(20), height: 260, decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.network(d['cover'], fit: BoxFit.cover, width: double.infinity)), Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: LinearGradient(begin: Alignment.centerRight, colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.9)]))), Padding(padding: const EdgeInsets.all(30), child: Row(children: [Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text(d['synopsis']??"", maxLines: 2, style: const TextStyle(color: Colors.grey))])), const SizedBox(width: 20), TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: d['id'], source: p, title: d['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(d['cover'], width: 150, fit: BoxFit.cover)))]))]));
  Widget _chips(WidgetRef ref, String s) => SizedBox(height: 60, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 20), children: ["Melolo","FreeReels","FlickReels","RapidTV"].map((p)=>Padding(padding: const EdgeInsets.only(right: 15), child: TVButton(onTap: ()=>ref.read(platformProvider.notifier).state=p.toLowerCase(), child: Container(padding: const EdgeInsets.symmetric(horizontal: 30), alignment: Alignment.center, decoration: BoxDecoration(color: s==p.toLowerCase()?const Color(0xFF8B5CF6):Colors.white10, borderRadius: BorderRadius.circular(15)), child: Text(p, style: const TextStyle(fontWeight: FontWeight.bold)))))).toList()));
}
EOF

cat <<'EOF' > lib/ui/mobile/mobile_home.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_providers.dart';
import '../player/player_screen.dart';
import '../shared/widgets.dart';
class MobileHome extends ConsumerWidget {
  const MobileHome({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final ds = ref.watch(dramasProvider);
    final bn = ref.watch(bannerProvider);
    final selP = ref.watch(platformProvider);
    final selC = ref.watch(categoryProvider);
    return Scaffold(backgroundColor: const Color(0xFF0D1117), appBar: AppBar(backgroundColor: const Color(0xFF161B22), elevation: 0, title: const Text("Livego")), body: SingleChildScrollView(child: Column(children: [
      bn.when(data: (d)=>d==null?const SizedBox():_b(context, d, selP), loading: ()=>const SizedBox(height: 180), error: (_,__)=>const SizedBox()),
      const Divider(color: Colors.white10, indent: 15, endIndent: 15),
      _chips(ref, ["Melolo","FreeReels","FlickReels","RapidTV"], selP, true),
      _chips(ref, ["Dubbing","Populer","New","Trending"], selC, false),
      ds.when(data: (list)=>GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.62, mainAxisSpacing: 10, crossAxisSpacing: 10), itemCount: list.length, itemBuilder: (c,i)=>TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: list[i]['id'], source: selP, title: list[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(list[i]['cover'], fit: BoxFit.cover)))), loading: ()=>const Center(child: CircularProgressIndicator()), error: (_,__)=>const SizedBox())
    ])));
  }
  Widget _b(BuildContext ctx, Map d, String p) => Container(margin: const EdgeInsets.all(15), height: 180, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(d['cover'], fit: BoxFit.cover, width: double.infinity)), Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black, Colors.transparent]))), Padding(padding: const EdgeInsets.all(15), child: Text(d['title'], style: const TextStyle(fontWeight: FontWeight.bold)))]));
  Widget _chips(WidgetRef ref, List<String> l, String s, bool isP) => SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: l.length, itemBuilder: (ctx, i)=>Padding(padding: const EdgeInsets.only(right: 8), child: TVButton(onTap: ()=>isP?ref.read(platformProvider.notifier).state=l[i].toLowerCase():ref.read(categoryProvider.notifier).state=l[i], child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: s.toLowerCase()==l[i].toLowerCase()||s==l[i]?(isP?const Color(0xFF8B5CF6):const Color(0xFF00D9FF)):Colors.white10, borderRadius: BorderRadius.circular(20)), alignment: Alignment.center, child: Text(l[i]))))));
}
EOF

echo "6. Menghubungkan Navigasi Utama..."
cat <<'EOF' > lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/mobile/mobile_home.dart';
import 'ui/tv/tv_home.dart';
void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const ProviderScope(child: LivegoApp())); }
class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override Widget build(BuildContext context) { return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const MainSwitcher()); }
}
class MainSwitcher extends StatefulWidget {
  const MainSwitcher({super.key});
  @override State<MainSwitcher> createState() => _MainSwitcherState();
}
class _MainSwitcherState extends State<MainSwitcher> {
  int _idx = 0;
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return isT ? TVHome() : MobileHome();
  }
}
EOF

echo "Push ke GitHub..."
git add . && git commit -m "Build 125 FINAL: TOTAL UI CLONE + PLAYER FIXED" && git push origin main --force
echo "--- EKSEKUSI SELESAI ---"
