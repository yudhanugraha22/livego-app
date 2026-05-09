import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        const SizedBox(height: 50),
        _header(),
        const SizedBox(height: 25),
        _label("KOLEKSI CEPAT"),
        _card([
          _item(context, Icons.history, "Riwayat", "Lanjutkan tontonan terakhir", () {}),
          _item(context, Icons.favorite_border, "Favorit", "Drama yang Anda simpan", () {}),
          _item(context, Icons.settings_outlined, "Pengaturan", "Tampilan, Player, DRM", () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsDetailPage()));
          }),
        ]),
        _label("DUKUNGAN"),
        _card([
          _item(context, Icons.system_update_alt, "Periksa Pembaruan", "Versi v1.0.0", () {}),
          _item(context, Icons.message_outlined, "Kirim Feedback", "Hubungi Developer", () {}),
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

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)));
  Widget _card(List<Widget> i) => Container(margin: const EdgeInsets.only(bottom: 25), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Column(children: i));
  Widget _item(BuildContext ctx, IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right, size: 16)));
}

class SettingsDetailPage extends StatefulWidget {
  const SettingsDetailPage({super.key});
  @override State<SettingsDetailPage> createState() => _SettingsDetailPageState();
}

class _SettingsDetailPageState extends State<SettingsDetailPage> {
  String nav = "Otomatis", drm = "Auto";
  bool bg = true, cache = true, rot = true;

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Livego"), backgroundColor: const Color(0xFF161B22)),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        _group("TAMPILAN & NAVIGASI", [
          _tile(Icons.settings_suggest, "Navigasi Hardware", nav, () {}),
        ]),
        _group("PLAYER", [
          _switch(Icons.image, "Background Poster", bg, (v)=>setState(()=>bg=v)),
          _switch(Icons.cached, "Gunakan Cache Playback", cache, (v)=>setState(()=>cache=v)),
          _switch(Icons.screen_rotation, "Tombol Rotasi Manual", rot, (v)=>setState(()=>rot=v)),
          _tile(Icons.lock, "Widevine DRM", drm, () {}),
        ]),
        _group("PERAWATAN", [
          _tile(Icons.delete_sweep, "Hapus Semua Cache", "Bersihkan memori", () {}, color: Colors.redAccent),
        ]),
      ]),
    );
  }

  Widget _group(String t, List<Widget> i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))), Container(margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(15)), child: Column(children: i))]);
  Widget _tile(IconData i, String t, String s, VoidCallback c, {Color? color}) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: color ?? Colors.blueAccent), title: Text(t, style: TextStyle(color: color)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right)));
  Widget _switch(IconData i, String t, bool v, Function(bool) c) => TVButton(onTap: () => c(!v), child: SwitchListTile(secondary: Icon(i, color: Colors.blueAccent), title: Text(t, style: const TextStyle(fontSize: 14)), value: v, onChanged: c, activeColor: Colors.blueAccent));
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Riwayat"))); }
}
class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Favorit"))); }
}
