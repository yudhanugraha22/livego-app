import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}
class _AccountPageState extends State<AccountPage> {
  String drm = "Auto"; bool cache = true;
  @override void initState() { super.initState(); _L(); }
  _L() async { final p = await SharedPreferences.getInstance(); setState(() => drm = p.getString('drm') ?? "Auto"); }
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0D1117), body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      _card([const ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white)), title: Text("User Penggemar"), subtitle: Text("Akun Livego Premium"))]),
      _label("PENGATURAN SYSTEM"),
      _card([_item(Icons.lock, "Widevine DRM", drm), _switch(Icons.cached, "Gunakan Cache", cache, (v)=>setState(()=>cache=v))]),
      _label("KOLEKSI"),
      _card([_item(Icons.history, "Riwayat", "Lihat"), _item(Icons.favorite, "Favorit", "Drama")]),
    ]));
  }
  _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, top: 20, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)));
  _card(List<Widget> i) => Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Column(children: i));
  _item(IconData i, String t, String s) => TVButton(onTap: (){}, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right, size: 16)));
  _switch(IconData i, String t, bool v, Function(bool) c) => TVButton(onTap: () => c(!v), child: SwitchListTile(secondary: Icon(i, color: Colors.blueAccent), title: Text(t), value: v, onChanged: c, activeColor: Colors.blueAccent));
}
