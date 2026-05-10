import 'package:flutter/material.dart';
import '../core/storage.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}
class _AccountPageState extends State<AccountPage> {
  String drm = "Auto"; bool cache = true;
  @override void initState() { super.initState(); _L(); }
  _L() async { drm = await LiveStorage.get('drmMode', "Auto"); setState(() {}); }

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0D1117), body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      _card([const ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white)), title: Text("User Penggemar"), subtitle: Text("Livego Premium"))]),
      const SizedBox(height: 20),
      _label("PENGATURAN SYSTEM"),
      _card([
        _item(Icons.lock, "Widevine DRM", drm, (){}),
        _switch(Icons.cached, "Gunakan Cache Playback", cache, (v)=>setState(()=>cache=v)),
        _item(Icons.delete_forever, "Hapus Semua Riwayat", "Bersihkan Memori", _clearAll),
      ]),
    ]));
  }
  _clearAll() { /* Logika clear list */ }
  _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)));
  _card(List<Widget> i) => Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.only(bottom: 20), child: Column(children: i));
  _item(IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right)));
  _switch(IconData i, String t, bool v, Function(bool) c) => TVButton(onTap: () => c(!v), child: SwitchListTile(secondary: Icon(i, color: Colors.blueAccent), title: Text(t), value: v, onChanged: c, activeColor: Colors.blueAccent));
}
