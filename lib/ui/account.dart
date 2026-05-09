import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String nav = "Otomatis", drm = "Auto";
  bool bg = true, cache = true, rot = true;

  @override void initState() { super.initState(); _L(); }
  _L() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      nav = p.getString('nav') ?? "Otomatis";
      drm = p.getString('drm') ?? "Auto";
      bg = p.getBool('bg') ?? true;
      cache = p.getBool('cache') ?? true;
      rot = p.getBool('rot') ?? true;
    });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        const SizedBox(height: 50),
        _header(),
        const SizedBox(height: 25),
        _group("KOLEKSI CEPAT", [
          _item(Icons.history, "Riwayat", "Tontonan terakhir", () {}),
          _item(Icons.favorite_border, "Favorit", "Drama tersimpan", () {}),
        ]),
        _group("PENGATURAN SYSTEM", [
          _item(Icons.settings_suggest, "Navigasi Hardware", nav, () {}),
          _item(Icons.lock_outline, "Widevine DRM", drm, () {}),
          _item(Icons.delete_sweep, "Hapus Semua Cache", "Bersihkan memori", () {}),
        ]),
      ]),
    );
  }
  Widget _header() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: const Row(children: [CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.person, color: Colors.white)), SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("User Penggemar", style: TextStyle(fontWeight: FontWeight.bold)), Text("Akun Livego", style: TextStyle(color: Colors.grey, fontSize: 12))])]));
  Widget _group(String t, List<Widget> i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))), Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.only(bottom: 20), child: Column(children: i))]);
  Widget _item(IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right, size: 16)));
}
