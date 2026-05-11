import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared/widgets.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override State<AccountScreen> createState() => _AccountScreenState();
}
class _AccountScreenState extends State<AccountScreen> {
  String nav = "Otomatis", drm = "Auto"; bool cache = true;
  @override void initState() { super.initState(); _L(); }
  _L() async { final p = await SharedPreferences.getInstance(); setState(() { nav = p.getString('navType') ?? "Otomatis"; drm = p.getString('drmMode') ?? "Auto"; cache = p.getBool('useCache') ?? true; }); }
  _S(String k, dynamic v) async { final p = await SharedPreferences.getInstance(); if(v is String) p.setString(k, v); else p.setBool(k, v); }

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF05070D), body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF161B22), Color(0xFF05070D)])), child: Row(children: [const CircleAvatar(radius: 35, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white, size: 40)), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("User Penggemar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text("LiveGo Premium", style: TextStyle(color: Color(0xFF00D9FF), fontSize: 13))])])),
      const SizedBox(height: 25),
      _g("PENGATURAN SYSTEM", [
        _i(Icons.settings, "Navigasi", nav, _showNav),
        _switch(Icons.cached, "Gunakan Cache", cache, (v){ setState(()=>cache=v); _S('useCache',v); }),
        _i(Icons.lock, "Widevine DRM", drm, _showDRM),
        _i(Icons.layers, "Sumber Data", "24 API", (){}),
      ]),
      _g("KOLEKSI", [ _i(Icons.history, "Riwayat", "Lihat", (){}), _i(Icons.favorite, "Favorit", "Lihat", (){}) ]),
    ]));
  }
  void _showNav() => _dialog("Navigasi", ["Otomatis", "Smartphone", "Android TV"], nav, (v){ setState(()=>nav=v); _S('navType',v); });
  void _showDRM() => _dialog("DRM Mode", ["Auto", "Paksa L3"], drm, (v){ setState(()=>drm=v); _S('drmMode',v); });
  void _dialog(String t, List<String> o, String g, Function(String) s) => showDialog(context: context, builder: (c)=>AlertDialog(title: Text(t), backgroundColor: const Color(0xFF161B22), content: Column(mainAxisSize: MainAxisSize.min, children: o.map((v)=>RadioListTile(title: Text(v), value: v, groupValue: g, onChanged: (x){s(x!); Navigator.pop(c);})).toList())));
  Widget _g(String t, List<Widget> i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 10, bottom: 10), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))), Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(24)), margin: const EdgeInsets.only(bottom: 25), child: Column(children: i))]);
  Widget _i(IconData i, String t, String s, [VoidCallback? c]) => TVButton(onTap: c??(){}, child: ListTile(leading: Icon(i, color: const Color(0xFF00D9FF)), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right)));
  Widget _switch(IconData i, String t, bool v, Function(bool) c) => TVButton(onTap: () => c(!v), child: SwitchListTile(secondary: Icon(i, color: const Color(0xFF00D9FF)), title: Text(t), value: v, onChanged: c, activeColor: const Color(0xFF00D9FF)));
}
