import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const LivegoApp());

class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        primaryColor: const Color(0xFF8B5CF6),
      ),
      home: const MainNavigation(),
    );
  }
}

class TVButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const TVButton({super.key, required this.child, required this.onTap});
  @override State<TVButton> createState() => _TVButtonState();
}
class _TVButtonState extends State<TVButton> {
  bool _isF = false;
  @override Widget build(BuildContext context) {
    return Focus(onFocusChange: (f)=>setState(()=>_isF=f), child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 150), decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: _isF ? Colors.blueAccent : Colors.transparent, width: 3.5), boxShadow: _isF ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.8), blurRadius: 20, spreadRadius: 3)] : []), transform: _isF ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(), child: widget.child)));
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override State<MainNavigation> createState() => _MainNavigationState();
}
class _MainNavigationState extends State<MainNavigation> {
  int _idx = 0;
  @override Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: [const HomePage(), const Center(child: Text("Halaman Unduhan")), const AccountPage()]),
      bottomNavigationBar: BottomNavigationBar(currentIndex: _idx, onTap: (i)=>setState(()=>_idx=i), backgroundColor: const Color(0xFF161B22), selectedItemColor: Colors.blueAccent, type: BottomNavigationBarType.fixed, items: const [BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "HOME"), BottomNavigationBarItem(icon: Icon(Icons.download_rounded), label: "UNDUHAN"), BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "AKUN")]),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final List<String> sources = ["Melolo", "DramaBox", "DotDrama", "Netshort", "Stardusttv", "Reelife", "DramaBite", "Velolo"];
  String selSource = "Melolo";
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF161B22), elevation: 0, title: const Text("Livego", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
      body: ListView(children: [
        const SizedBox(height: 15),
        _banner(),
        const SizedBox(height: 15),
        _hList(sources, selSource, (v)=>setState(()=>selSource=v), const Color(0xFF8B5CF6)),
        const SizedBox(height: 10),
        _hList(["Populer", "New", "Trend"], "Populer", (v){}, Colors.blueAccent),
        _grid(isT),
      ]),
    );
  }
  Widget _banner() => Container(margin: const EdgeInsets.symmetric(horizontal: 15), child: TVButton(onTap: (){}, child: Container(height: 170, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white10), alignment: Alignment.center, child: const Text("Banner Mewah Build #28"))));
  Widget _hList(List l, String s, Function(String) o, Color c) => SizedBox(height: 40, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: l.length, itemBuilder: (ctx, i)=>Padding(padding: const EdgeInsets.only(right: 8), child: TVButton(onTap: ()=>o(l[i]), child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), alignment: Alignment.center, decoration: BoxDecoration(color: s == l[i] ? c : Colors.white10, borderRadius: BorderRadius.circular(20)), child: Text(l[i]))))));
  Widget _grid(bool isT) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isT?7:4, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: isT?14:12, itemBuilder: (c, i) => TVButton(onTap: (){}, child: Container(decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.play_arrow, color: Colors.white10))));
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(25)), child: Column(children: [Row(children: [const CircleAvatar(radius: 35, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white, size: 40)), const SizedBox(width: 15), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("User Penggemar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("Akun CineFlow", style: TextStyle(color: Colors.grey))])]), const SizedBox(height: 15), Row(children: [ _btn("Telegram"), const SizedBox(width: 10), _btn("WhatsApp") ])])),
      const SizedBox(height: 25),
      _group("KOLEKSI CEPAT", [ _item(Icons.history, "Riwayat"), _item(Icons.favorite_border, "Favorit"), _item(Icons.settings, "Pengaturan") ]),
    ]));
  }
  Widget _btn(String t) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white10), child: Text(t, style: const TextStyle(fontSize: 12)));
  Widget _group(String t, List<Widget> i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))), Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Column(children: i)), const SizedBox(height: 20)]);
  Widget _item(IconData i, String t) => TVButton(onTap: (){}, child: ListTile(leading: Icon(i, color: Colors.white70), title: Text(t), trailing: const Icon(Icons.chevron_right, size: 16)));
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(25)), child: Column(children: [Row(children: [const CircleAvatar(radius: 35, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white, size: 40)), const SizedBox(width: 15), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("User Penggemar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("Akun CineFlow", style: TextStyle(color: Colors.grey))])]), const SizedBox(height: 15), Row(children: [ _btn("Telegram"), const SizedBox(width: 10), _btn("WhatsApp") ])])),
      const SizedBox(height: 25),
      _group("KOLEKSI CEPAT", [ _item(Icons.history, "Riwayat"), _item(Icons.favorite_border, "Favorit"), _item(Icons.settings, "Pengaturan") ]),
    ]));
  }
  Widget _btn(String t) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white10), child: Text(t, style: const TextStyle(fontSize: 12)));
  Widget _group(String t, List<Widget> i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))), Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Column(children: i)), const SizedBox(height: 20)]);
  Widget _item(IconData i, String t) => TVButton(onTap: (){}, child: ListTile(leading: Icon(i, color: Colors.white70), title: Text(t), trailing: const Icon(Icons.chevron_right, size: 16)));
}
