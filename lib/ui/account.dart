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
  _S(String k, String v) async { final p = await SharedPreferences.getInstance(); p.setString(k, v); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        const SizedBox(height: 50),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: const Row(children: [CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.person, color: Colors.white)), SizedBox(width: 15), Text("User Penggemar", style: TextStyle(fontWeight: FontWeight.bold))])),
        const SizedBox(height: 20),
        _group("PENGATURAN SYSTEM", [
          _item(Icons.lock, "Widevine DRM", drm, _showDRM),
          _switch(Icons.cached, "Gunakan Cache", cache, (v) => setState(() => cache = v)),
          _item(Icons.layers, "Kelola Sumber Data", "4 API Aktif", (){}),
        ]),
        _group("DUKUNGAN", [ _item(Icons.update, "Cek Pembaruan", "v1.0.0", (){}), _item(Icons.message, "Feedback", "Dukungan", (){}) ]),
      ]),
    );
  }
  void _showDRM() => showDialog(context: context, builder: (c) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text("DRM"), content: Column(mainAxisSize: MainAxisSize.min, children: ["Auto", "Paksa L3"].map((v) => RadioListTile(title: Text(v), value: v, groupValue: drm, onChanged: (x){ setState(()=>drm=x!); _S('drm', x!); Navigator.pop(c); })).toList())));
  Widget _group(String t, List<Widget> i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))), Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Column(children: i)), const SizedBox(height: 20)]);
  Widget _item(IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right, size: 16)));
  Widget _switch(IconData i, String t, bool v, Function(bool) c) => TVButton(onTap: () => c(!v), child: SwitchListTile(secondary: Icon(i, color: Colors.blueAccent), title: Text(t), value: v, onChanged: c, activeColor: Colors.blueAccent));
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Riwayat"))); }
}
class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Favorit"))); }
}
