import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String nav = "Otomatis", drm = "Auto";
  bool bg = false, cache = true, rot = true;

  @override void initState() { super.initState(); _L(); }
  _L() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      nav = p.getString('nav') ?? "Otomatis";
      drm = p.getString('drm') ?? "Auto";
      bg = p.getBool('bg') ?? false;
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
        _label("KOLEKSI CEPAT"),
        _card([
          _item(context, Icons.history, "Riwayat", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryPage()))),
          _item(context, Icons.favorite, "Favorit", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FavoritePage()))),
        ]),
        const SizedBox(height: 20),
        _label("PENGATURAN SISTEM"),
        _card([
          _item(context, Icons.settings_suggest, "Navigasi Hardware", () {}),
          _item(context, Icons.lock_outline, "Widevine DRM", () {}),
        ]),
        const SizedBox(height: 20),
        _label("DUKUNGAN"),
        _card([
          _item(context, Icons.system_update_alt, "Cek Pembaruan Livego", () {}),
          _item(context, Icons.message_outlined, "Feedback Dukungan", () {}),
        ]),
      ]),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(25)),
    child: Row(children: [
      const CircleAvatar(radius: 35, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white, size: 40)),
      const SizedBox(width: 15),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("User Penggemar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("Akun Livego", style: TextStyle(color: Colors.grey, fontSize: 13)),
      ]),
    ]),
  );

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey)));
  Widget _card(List<Widget> i) => Container(margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Column(children: i));
  
  // FIX PARAMETER: Sekarang menerima 4 data sesuai pemanggilan
  Widget _item(BuildContext context, IconData i, String t, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t, style: const TextStyle(fontSize: 14)), trailing: const Icon(Icons.chevron_right, size: 16)));
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Riwayat Livego")), body: const Center(child: Text("Kosong"))); }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Favorit Livego")), body: const Center(child: Text("Kosong"))); }
}
