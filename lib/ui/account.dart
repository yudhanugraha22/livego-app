import 'package:flutter/material.dart';
import '../core/storage.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}
class _AccountPageState extends State<AccountPage> {
  String drm = "Auto", nav = "Otomatis"; bool cache = true;
  @override void initState() { super.initState(); _L(); }
  _L() async { drm = await LiveStorage.get('drm', "Auto"); nav = await LiveStorage.get('nav', "Otomatis"); cache = await LiveStorage.get('cache', true); setState(() {}); }

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0D1117), body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      _card([const ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white)), title: Text("User Penggemar"), subtitle: Text("Akun Livego Premium"))]),
      const SizedBox(height: 20),
      _group("PENGATURAN SYSTEM", [
        _item(Icons.settings, "Navigasi Hardware", nav, _showNav),
        _switch(Icons.cached, "Gunakan Cache Playback", cache, (v){ setState(()=>cache=v); LiveStorage.save('cache', v); }),
        _item(Icons.lock, "Widevine DRM", drm, _showDRM),
      ]),
      _group("KOLEKSI", [ _item(Icons.history, "Riwayat", "Lihat", (){}), _item(Icons.favorite, "Favorit", "Drama", (){}) ]),
    ]));
  }
  void _showNav() => _dialog("Navigasi", ["Otomatis", "Smartphone", "Android TV"], nav, (v){ setState(()=>nav=v); LiveStorage.save('nav',v); });
  void _showDRM() => _dialog("DRM", ["Auto", "Paksa L3"], drm, (v){ setState(()=>drm=v); LiveStorage.save('drm',v); });
  void _dialog(String t, List<String> o, String g, Function(String) s) => showDialog(context: context, builder: (c)=>AlertDialog(title: Text(t), backgroundColor: const Color(0xFF161B22), content: Column(mainAxisSize: MainAxisSize.min, children: o.map((v)=>RadioListTile(title: Text(v), value: v, groupValue: g, onChanged: (x){s(x!); Navigator.pop(c);})).toList())));
  Widget _group(String t, List<Widget> i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.only(bottom: 20), child: Column(children: i))]);
  Widget _item(IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.blueAccent)), trailing: const Icon(Icons.chevron_right, size: 16)));
  Widget _switch(IconData i, String t, bool v, Function(bool) c) => TVButton(onTap: () => c(!v), child: SwitchListTile(secondary: Icon(i, color: Colors.blueAccent), title: Text(t), value: v, onChanged: c, activeColor: Colors.blueAccent));
  Widget _card(List<Widget> i) => Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Column(children: i));
}
