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
  _S(String k, dynamic v) async { final p = await SharedPreferences.getInstance(); if(v is String) p.setString(k, v); else p.setBool(k, v); }

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0D1117), body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      _card([const ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white)), title: Text("User Penggemar"), subtitle: Text("Livego Premium"))]),
      const SizedBox(height: 20),
      _label("PENGATURAN SYSTEM"),
      _card([
        _item(Icons.settings, "Navigasi Hardware", "Otomatis", (){}),
        _switch(Icons.cached, "Gunakan Cache Playback", cache, (v){ setState(()=>cache=v); _S('cache',v); }),
        _item(Icons.lock, "Widevine DRM", drm, _showDRM),
        _item(Icons.layers, "Kelola Sumber Data", "24 API", _goAPI),
      ]),
      _label("KOLEKSI"),
      _card([ _item(Icons.history, "Riwayat", "Lihat", (){}), _item(Icons.favorite, "Favorit", "Drama", (){}) ]),
    ]));
  }
  void _showDRM() => showDialog(context: context, builder: (c)=>AlertDialog(title: const Text("DRM"), backgroundColor: const Color(0xFF161B22), content: Column(mainAxisSize: MainAxisSize.min, children: ["Auto", "Paksa L3"].map((v)=>RadioListTile(title: Text(v), value: v, groupValue: drm, onChanged: (x){setState(()=>drm=x!); _S('drm',x!); Navigator.pop(c);})).toList())));
  void _goAPI() => Navigator.push(context, MaterialPageRoute(builder: (c)=>const SourceManager()));
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)));
  Widget _card(List<Widget> i) => Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.only(bottom: 20), child: Column(children: i));
  Widget _item(IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.blueAccent)), trailing: const Icon(Icons.chevron_right, size: 16)));
  Widget _switch(IconData i, String t, bool v, Function(bool) c) => TVButton(onTap: () => c(!v), child: SwitchListTile(secondary: Icon(i, color: Colors.white70), title: Text(t, style: const TextStyle(fontSize: 14)), value: v, onChanged: c, activeColor: Colors.blueAccent));
}

class SourceManager extends StatefulWidget {
  const SourceManager({super.key});
  @override State<SourceManager> createState() => _SourceManagerState();
}
class _SourceManagerState extends State<SourceManager> {
  final List<String> all = ["Melolo", "DramaBox", "Netshort", "Goodshort", "Shortmax", "DramaWave", "FlickReels", "FreeReels", "ReelShort", "Meloshort", "FlexTV", "DramaRush", "RapidTV", "StardustTV", "Dramanova", "Fundrama", "Starshort", "Dramapops", "Snackshort", "Reelife", "Dramabite", "Sodareels", "Bilitv", "iDrama"];
  Map<String, bool> s = {};
  @override void initState() { super.initState(); _load(); }
  _load() async { final p = await SharedPreferences.getInstance(); setState(() { for (var a in all) { s[a] = p.getBool('api_$a') ?? ["Melolo","FreeReels","FlickReels","RapidTV"].contains(a); } }); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Kelola 24 API")), body: ListView(padding: const EdgeInsets.all(15), children: s.keys.map((k)=>Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(15)), child: TVButton(onTap: () async { setState(()=>s[k]=!s[k]!); final p = await SharedPreferences.getInstance(); p.setBool('api_$k', s[k]!); }, child: SwitchListTile(title: Text(k), value: s[k]!, onChanged: (v){}, activeColor: Colors.blueAccent)))).toList()));
  }
}
