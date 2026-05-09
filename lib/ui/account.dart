import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}
class _AccountPageState extends State<AccountPage> {
  String nav = "Otomatis", drm = "Auto"; bool cache = true;
  @override void initState() { super.initState(); _L(); }
  _L() async { final p = await SharedPreferences.getInstance(); setState(() { nav = p.getString('nav') ?? "Otomatis"; drm = p.getString('drm') ?? "Auto"; cache = p.getBool('cache') ?? true; }); }
  _S(String k, dynamic v) async { final p = await SharedPreferences.getInstance(); if(v is String) p.setString(k, v); else p.setBool(k, v); }

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0D1117), body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      _card([const ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white)), title: Text("User Penggemar"), subtitle: Text("Akun Livego Premium"))]),
      _label("PENGATURAN SYSTEM"),
      _card([
        _item(Icons.settings, "Navigasi Hardware", nav, _showNav),
        _switch(Icons.cached, "Gunakan Cache Playback", cache, (v){ setState(()=>cache=v); _S('cache',v); }),
        _item(Icons.lock, "Widevine DRM", drm, _showDRM),
      ]),
      _label("KOLEKSI"),
      _card([ _item(Icons.history, "Riwayat Tontonan", "Lihat", (){}), _item(Icons.favorite, "Favorit Saya", "Lihat", (){}) ]),
    ]));
  }
  void _showNav() => _dialog("Navigasi", ["Otomatis", "Smartphone", "Android TV"], (v){ setState(()=>nav=v); _S('nav',v); });
  void _showDRM() => _dialog("DRM", ["Auto", "Paksa L3", "Berhenti L3"], (v){ setState(()=>drm=v); _S('drm',v); });
  void _dialog(String t, List<String> o, Function(String) s) => showDialog(context: context, builder: (c)=>AlertDialog(title: Text(t), backgroundColor: const Color(0xFF161B22), content: Column(mainAxisSize: MainAxisSize.min, children: o.map((v)=>ListTile(title: Text(v), onTap: (){ s(v); Navigator.pop(c); })).toList())));
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, top: 20, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)));
  Widget _card(List<Widget> i) => Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.only(bottom: 10), child: Column(children: i));
  Widget _item(IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.blueAccent)), trailing: const Icon(Icons.chevron_right, size: 16)));
  Widget _switch(IconData i, String t, bool v, Function(bool) c) => TVButton(onTap: ()=>c(!v), child: SwitchListTile(secondary: Icon(i, color: Colors.white70), title: Text(t), value: v, onChanged: c, activeColor: Colors.blueAccent));
}
