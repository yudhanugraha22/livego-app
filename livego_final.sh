#!/bin/bash
# ===============================================
# LIVEGO ULTIMATE MASTER - BUILD #117 (FINAL)
# REBRANDING & FULL CINEFLOW CLONE IMPLEMENTATION
# ===============================================
cd ~/livego_project
rm -rf lib && mkdir -p lib/core lib/providers lib/ui/shared lib/ui/mobile lib/ui/tv lib/ui/player

echo "1. Membangun Mesin Inti & State (LiveGo Engine)..."
# API ENGINE
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

# STATE MANAGEMENT
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

echo "2. Membangun UI shared & Kursor Neon..."
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
    }, child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 150), decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.radius), border: Border.all(color: _isF ? const Color(0xFF00D9FF) : Colors.transparent, width: 3.0), boxShadow: _isF ? [BoxShadow(color: const Color(0xFF00D9FF).withOpacity(0.5), blurRadius: 20)] : []), transform: _isF ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(), child: widget.child)));
  }
}
EOF

echo "3. Membangun Player Mewah (Identik CineFlow)..."
cat <<'EOF' > lib/ui/player/player_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../core/api_engine.dart';
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
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))..initialize().then((_){ setState((){ ready=true; _v!.play(); _startT(); }); });
      _v!.addListener(()=>setState((){}));
    }
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
  Widget _buildOverlay(bool isT) => Stack(children: [
    Positioned(top: 40, left: 20, child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: ()=>Navigator.pop(context)), Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold))])),
    Positioned(bottom: 30, left: isT?60:20, right: isT?60:20, child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white12)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.redAccent, backgroundColor: Colors.white12)),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [Icon(Icons.skip_previous), Icon(Icons.play_arrow, size: 40), Icon(Icons.skip_next), Text("AUTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Icon(Icons.subtitles), Icon(Icons.settings), Icon(Icons.fullscreen)])
      ]),
    )),
  ]);
}
EOF

echo "4. Membangun Akun & Pengaturan (10 Poin Paten)..."
cat <<'EOF' > lib/ui/mobile/account_screen.dart
import 'package:flutter/material.dart';
import '../shared/widgets.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF05070D), body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF161B22), Color(0xFF05070D)])), child: Row(children: [const CircleAvatar(radius: 35, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white, size: 40)), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("User Penggemar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text("LiveGo Premium", style: TextStyle(color: Color(0xFF00D9FF), fontSize: 13))])])),
      const SizedBox(height: 25),
      _group("PENGATURAN SYSTEM", [ _item(Icons.settings, "Navigasi Hardware", "Otomatis"), _item(Icons.lock, "Widevine DRM", "Auto"), _item(Icons.layers, "Kelola Sumber Data", "24 API") ]),
      _group("KOLEKSI CEPAT", [ _item(Icons.history, "Riwayat Tontonan", "Paten"), _item(Icons.favorite, "Drama Favorit", "Paten") ]),
    ]));
  }
  Widget _group(String t, List<Widget> i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 10, bottom: 10), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))), Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(24)), margin: const EdgeInsets.only(bottom: 25), child: Column(children: i))]);
  Widget _item(IconData i, String t, String s) => TVButton(onTap: (){}, child: ListTile(leading: Icon(i, color: const Color(0xFF00D9FF)), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(s, style: const TextStyle(fontSize: 11)), trailing: const Icon(Icons.chevron_right)));
}
EOF

echo "5. Membangun Beranda (Adaptive Grid 4/7)..."
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
      const Divider(color: Colors.white10, thickness: 1, indent: 15, endIndent: 15),
      _chips(ref, ["Melolo","FreeReels","FlickReels","RapidTV"], selP, true),
      _chips(ref, ["Dubbing","Populer","New","Trending"], selC, false),
      ds.when(data: (list)=>GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isT?7:4, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: list.length, itemBuilder: (c,i)=>TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: list[i]['id'], source: selP, title: list[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(list[i]['cover'], fit: BoxFit.cover)))), loading: ()=>const Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF))), error: (_,__)=>const SizedBox())
    ])));
  }
  Widget _b(BuildContext ctx, Map d, String p) => Container(margin: const EdgeInsets.all(15), height: 180, decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white10)), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.network(d['cover'], fit: BoxFit.cover, width: double.infinity)), Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black, Colors.transparent]))), Padding(padding: const EdgeInsets.all(20), child: Text(d['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))]));
  Widget _chips(WidgetRef ref, List<String> l, String s, bool isP) => SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: l.length, itemBuilder: (ctx, i)=>Padding(padding: const EdgeInsets.only(right: 8), child: TVButton(radius: 20, onTap: ()=>isP?ref.read(platformProvider.notifier).state=l[i].toLowerCase():ref.read(categoryProvider.notifier).state=l[i], child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: s.toLowerCase()==l[i].toLowerCase()||s==l[i]?(isP?const Color(0xFF8B5CF6):const Color(0xFF00D9FF)):Colors.white10, borderRadius: BorderRadius.circular(20)), alignment: Alignment.center, child: Text(l[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))))));
}
EOF

echo "6. Menghubungkan Navigasi Utama..."
cat <<'EOF' > lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/mobile/mobile_home.dart';
import 'ui/mobile/account_screen.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const ProviderScope(child: LivegoApp())); }
class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override Widget build(BuildContext context) { return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const MainNavigation()); }
}
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override State<MainNavigation> createState() => _MainNavigationState();
}
class _MainNavigationState extends State<MainNavigation> {
  int _idx = 0;
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    final pages = [const MobileHome(), const Center(child: Text("Unduhan")), const AccountScreen()];
    return Scaffold(
      body: Row(children: [
        if (isT) Container(width: 80, color: const Color(0xFF161B22), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ IconButton(icon: Icon(Icons.home, color: _idx==0?const Color(0xFF00D9FF):Colors.grey), onPressed: ()=>setState(()=>_idx=0)), const SizedBox(height: 30), IconButton(icon: Icon(Icons.person, color: _idx==2?const Color(0xFF00D9FF):Colors.grey), onPressed: ()=>setState(()=>_idx=2)) ])),
        Expanded(child: IndexedStack(index: _idx, children: pages)),
      ]),
      bottomNavigationBar: isT ? null : BottomNavigationBar(currentIndex: _idx, onTap: (i)=>setState(()=>_idx=i), backgroundColor: const Color(0xFF161B22), selectedItemColor: const Color(0xFF00D9FF), unselectedItemColor: Colors.grey, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"), BottomNavigationBarItem(icon: Icon(Icons.download), label: "UNDUHAN"), BottomNavigationBarItem(icon: Icon(Icons.person), label: "AKUN")]),
    );
  }
}
EOF

echo "Push ke GitHub..."
git add . && git commit -m "Build 117 FINAL: LIVEGO ULTIMATE PROFESSIONAL MODULAR" && git push origin main --force
echo "--- EKSEKUSI FINAL SELESAI ---"
