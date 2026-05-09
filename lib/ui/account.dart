import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}
class _AccountPageState extends State<AccountPage> {
  String nav = "Otomatis", drm = "Auto";
  @override void initState() { super.initState(); _L(); }
  _L() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      nav = p.getString('nav') ?? "Otomatis";
      drm = p.getString('drm') ?? "Auto";
    });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        const SizedBox(height: 50),
        _card([const ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white)), title: Text("User Penggemar"), subtitle: Text("Livego Premium"))]),
        const SizedBox(height: 20),
        _label("KOLEKSI"),
        _card([
          _item(Icons.history, "Riwayat Tontonan", "Klik untuk buka", (){}),
          _item(Icons.favorite, "Favorit Saya", "Klik untuk buka", (){}),
        ]),
        _label("PENGATURAN SYSTEM"),
        _card([
          _item(Icons.settings, "Navigasi Hardware", nav, (){}),
          _item(Icons.lock, "Widevine DRM", drm, (){}),
          _item(Icons.delete_sweep, "Hapus Cache", "Bersihkan memori", (){}),
        ]),
      ]),
    );
  }
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)));
  Widget _card(List<Widget> i) => Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.only(bottom: 20), child: Column(children: i));
  Widget _item(IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right, size: 16)));
}
