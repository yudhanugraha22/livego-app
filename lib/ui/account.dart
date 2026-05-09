import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<String> favs = []; List<String> hist = [];
  @override void initState() { super.initState(); _L(); }
  _L() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      favs = p.getStringList('livego_favs') ?? [];
      hist = p.getStringList('livego_history') ?? [];
    });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        const SizedBox(height: 50),
        _header(),
        const SizedBox(height: 25),
        _label("KOLEKSI CEPAT"),
        _card([
          _item(context, Icons.history, "Riwayat", "${hist.length} Judul", () {}),
          _item(context, Icons.favorite, "Favorit", "${favs.length} Judul", () {}),
        ]),
        _label("PENGATURAN SYSTEM"),
        _card([
          _item(context, Icons.settings, "Navigasi", "Otomatis", () {}),
          _item(context, Icons.lock, "Widevine DRM", "Auto", () {}),
        ]),
      ]),
    );
  }

  Widget _header() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: const Row(children: [CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.person, color: Colors.white)), SizedBox(width: 15), Text("User Penggemar", style: TextStyle(fontWeight: FontWeight.bold))]));
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)));
  Widget _card(List<Widget> i) => Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.only(bottom: 20), child: Column(children: i));
  
  // FIX: Sekarang parameter sudah sinkron (5 argumen)
  Widget _item(BuildContext ctx, IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right, size: 16)));
}
