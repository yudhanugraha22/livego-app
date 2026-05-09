#!/bin/bash
rm -rf lib && mkdir -p lib/ui

# 1. FONDASI KURSOR (PATEN)
cat <<'E1' > lib/ui/widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class TVButton extends StatefulWidget {
  final Widget child; final VoidCallback onTap; final double borderRadius;
  const TVButton({super.key, required this.child, required this.onTap, this.borderRadius = 15});
  @override State<TVButton> createState() => _TVButtonState();
}
class _TVButtonState extends State<TVButton> {
  bool _isF = false;
  @override Widget build(BuildContext context) {
    return Focus(onFocusChange: (f)=>setState(()=>_isF=f), onKeyEvent: (n,e){
      if(e is KeyDownEvent && (e.logicalKey == LogicalKeyboardKey.select || e.logicalKey == LogicalKeyboardKey.enter)){
        widget.onTap(); return KeyEventResult.handled;
      } return KeyEventResult.ignored;
    }, child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 150), decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.borderRadius), border: Border.all(color: _isF ? Colors.cyanAccent : Colors.transparent, width: 3.5), boxShadow: _isF ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.8), blurRadius: 20)] : []), transform: _isF ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(), child: widget.child)));
  }
}
E1

# 2. MESIN API (PATEN)
cat <<'E2' > lib/ui/api_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
class ApiService {
  static const String secret = "22dfb2b849814054af0491ff2ee3ffe33989313d7d38e97aae659757a4cf8960";
  static Future<dynamic> get(String path) async {
    String ts = DateTime.now().millisecondsSinceEpoch.toString();
    var sig = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode("GET:$path:$ts"));
    try {
      final r = await http.get(Uri.parse("https://api-drama.dobda.id$path"), headers: {"X-Timestamp": ts, "X-Signature": sig.toString()});
      return r.statusCode == 200 ? json.decode(r.body) : null;
    } catch (e) { return null; }
  }
}
E2

# 3. HOME MEWAH (PATEN)
cat <<'E3' > lib/ui/home.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';
import 'api_service.dart';
import 'player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List ds = []; Map? banner; bool load = true; String plat = "melolo";
  List<String> active = [];

  @override void initState() { super.initState(); _init(); }
  _init() async {
    final p = await SharedPreferences.getInstance();
    final List<String> all = ["Melolo","FreeReels","FlickReels","RapidTV"];
    setState(() { active = all.where((a)=>p.getBool('api_$a')??true).toList(); });
    _fetch();
  }
  _fetch() async {
    setState(()=>load=true);
    final bRes = await ApiService.get("/api/v2/banner?category_p=$plat&lang=id");
    if (bRes != null && bRes['data'].isNotEmpty) banner = bRes['data'][0];
    final res = await ApiService.get("/api/v2/home?category_p=$plat&lang=id");
    if (res != null) setState((){ ds = res['data']; load = false; });
  }

  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(backgroundColor: const Color(0xFF0D1117), 
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text("Livego", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(child: Column(children: [
        if (banner != null) _bannerUI(),
        _chips(),
        load ? const Center(child: CircularProgressIndicator()) : _gridUI(isT),
      ])),
    );
  }
  Widget _bannerUI() => Container(height: 200, margin: const EdgeInsets.all(15), child: TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (c)=>PlayerPage(id: banner!['id'], source: plat, title: banner!['title']))), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(banner!['cover'], fit: BoxFit.cover, width: double.infinity)), Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black, Colors.transparent])), padding: const EdgeInsets.all(20), alignment: Alignment.bottomLeft, child: Text(banner!['title'], style: const TextStyle(fontWeight: FontWeight.bold)))])));
  Widget _chips() => SizedBox(height: 50, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: active.length, itemBuilder: (ctx, i)=>Padding(padding: const EdgeInsets.only(right: 10), child: TVButton(borderRadius: 20, onTap: (){ plat=active[i].toLowerCase(); _fetch(); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: plat==active[i].toLowerCase()?const Color(0xFF8B5CF6):Colors.white10, borderRadius: BorderRadius.circular(20)), alignment: Alignment.center, child: Text(active[i]))))));
  Widget _gridUI(bool isT) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isT?7:4, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: ds.length, itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c)=>PlayerPage(id: ds[i]['id'], source: plat, title: ds[i]['title']))), child: Column(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(ds[i]['cover'], fit: BoxFit.cover))), Text(ds[i]['title'], maxLines:1, style: const TextStyle(fontSize: 9))])));
}
E3

# 4. AKUN 10 POIN (PATEN)
cat <<'E4' > lib/ui/account.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}
class _AccountPageState extends State<AccountPage> {
  String drm = "Auto", nav = "Otomatis"; bool cache = true;
  @override void initState() { super.initState(); _L(); }
  _L() async { final p = await SharedPreferences.getInstance(); setState(() { drm = p.getString('drm') ?? "Auto"; nav = p.getString('nav') ?? "Otomatis"; cache = p.getBool('cache') ?? true; }); }
  _S(String k, dynamic v) async { final p = await SharedPreferences.getInstance(); if(v is String) p.setString(k, v); else p.setBool(k, v); }

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0D1117), body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      _card([const ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white)), title: Text("User Penggemar"), subtitle: Text("Livego Premium"))]),
      _group("PENGATURAN SYSTEM", [
        _item(Icons.settings, "Navigasi Hardware", nav, _showNav),
        _switch(Icons.cached, "Gunakan Cache", cache, (v){ setState(()=>cache=v); _S('cache',v); }),
        _item(Icons.lock, "Widevine DRM", drm, _showDRM),
      ]),
      _group("KOLEKSI", [ _item(Icons.history, "Riwayat", "Lihat", (){}), _item(Icons.favorite, "Favorit", "Lihat", (){}) ]),
    ]));
  }
  void _showNav() => _dialog("Navigasi", ["Otomatis", "Smartphone", "Android TV"], nav, (v){ setState(()=>nav=v); _S('nav',v); });
  void _showDRM() => _dialog("DRM", ["Auto", "Paksa L3"], drm, (v){ setState(()=>drm=v); _S('drm',v); });
  void _dialog(String t, List<String> o, String g, Function(String) s) => showDialog(context: context, builder: (c)=>AlertDialog(title: Text(t), backgroundColor: const Color(0xFF161B22), content: Column(mainAxisSize: MainAxisSize.min, children: o.map((v)=>RadioListTile(title: Text(v), value: v, groupValue: g, onChanged: (x){s(x!); Navigator.pop(c);})).toList())));
  Widget _group(String t, List<Widget> i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))), Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.only(bottom: 20), child: Column(children: i))]);
  Widget _item(IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right, size: 16)));
  Widget _switch(IconData i, String t, bool v, Function(bool) c) => TVButton(onTap: () => c(!v), child: SwitchListTile(secondary: Icon(i, color: Colors.blueAccent), title: Text(t), value: v, onChanged: c, activeColor: Colors.blueAccent));
  Widget _card(List<Widget> i) => Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Column(children: i));
}
E4

# 5. PLAYER PREMIUM (PATEN)
cat <<'E5' > lib/ui/player.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'widgets.dart';
import 'api_service.dart';

class PlayerPage extends StatefulWidget {
  final String id, source, title;
  const PlayerPage({super.key, required this.id, required this.source, required this.title});
  @override State<PlayerPage> createState() => _PlayerPageState();
}
class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _v; bool ready = false; bool ui = true; Timer? _t;
  @override void initState() { super.initState(); _init(); }
  _init() async {
    final res = await ApiService.get("/api/v2/video?category_p=${widget.source}&id=${widget.id}&chapterId=1&lang=id");
    if (res != null) {
      _v = VideoPlayerController.networkUrl(Uri.parse(res['data']['streams'][0]['url']))..initialize().then((_){ setState((){ ready=true; _v!.play(); _startT(); }); });
      _v!.addListener(()=>setState((){}));
    }
  }
  _startT() { _t?.cancel(); _t = Timer(const Duration(seconds: 5), () { if(mounted) setState(()=>ui=false); }); }
  @override void dispose() { _v?.dispose(); _t?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: GestureDetector(onTap: (){ setState(()=>ui=!ui); if(ui) _startT(); }, child: Stack(children: [
      Center(child: ready ? AspectRatio(aspectRatio: _v!.value.aspectRatio, child: VideoPlayer(_v!)) : const CircularProgressIndicator()),
      if (ui && ready) Positioned(bottom: 30, left: 40, right: 40, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF0D2A4F).withOpacity(0.9), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))), child: Column(mainAxisSize: MainAxisSize.min, children: [
        VideoProgressIndicator(_v!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.pinkAccent)),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [Icon(Icons.skip_previous), Icon(Icons.play_arrow, size: 40), Icon(Icons.skip_next), Text("AUTO"), Icon(Icons.list)])
      ]))),
    ])));
  }
}
E5

# 6. MAIN (SWITCHER)
cat <<'E6' > lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'ui/home.dart';
import 'ui/account.dart';
void main() => runApp(const LivegoApp());
class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black), home: const MainNavigation());
  }
}
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override State<MainNavigation> createState() => _MainNavigationState();
}
class _MainNavigationState extends State<MainNavigation> {
  int _idx = 0;
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(body: Row(children: [
      if (isT) Container(width: 70, color: const Color(0xFF161B22), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(icon: Icon(Icons.home, color: _idx==0?Colors.blue:Colors.grey), onPressed: ()=>setState(()=>_idx=0)), const SizedBox(height: 30), IconButton(icon: Icon(Icons.person, color: _idx==2?Colors.blue:Colors.grey), onPressed: ()=>setState(()=>_idx=2))])),
      Expanded(child: IndexedStack(index: _idx, children: [const HomePage(), const Center(child: Text("Halaman Unduhan")), const AccountPage()])),
    ]), bottomNavigationBar: isT ? null : BottomNavigationBar(currentIndex: _idx, onTap: (i)=>setState(()=>_idx=i), backgroundColor: const Color(0xFF161B22), selectedItemColor: Colors.blueAccent, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"), BottomNavigationBarItem(icon: Icon(Icons.download), label: "UNDUHAN"), BottomNavigationBarItem(icon: Icon(Icons.person), label: "AKUN")]));
  }
}
E6

git add . && git commit -m "Build 93: FINAL PATENT RECOVERY" && git push origin main --force
