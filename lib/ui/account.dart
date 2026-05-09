import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}
class _AccountPageState extends State<AccountPage> {
  String nav = "Otomatis", drm = "Auto"; bool bg = false;
  @override void initState() { super.initState(); _L(); }
  _L() async { final p = await SharedPreferences.getInstance(); setState(() { nav = p.getString('nav') ?? "Otomatis"; drm = p.getString('drm') ?? "Auto"; bg = p.getBool('bg') ?? false; }); }
  @override Widget build(BuildContext context) {
    return Scaffold(body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 40),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: const ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white)), title: Text("User Penggemar"), subtitle: Text("Akun CineFlow"))),
      const SizedBox(height: 20),
      _card([_item(Icons.history, "Riwayat", () => _go("Riwayat")), _item(Icons.favorite, "Favorit", () => _go("Favorit"))]),
      _card([_item(Icons.settings, "Widevine DRM ($drm)", (){}), _item(Icons.update, "Cek Update", (){})]),
    ]));
  }
  _go(String t) => Navigator.push(context, MaterialPageRoute(builder: (c)=>Scaffold(appBar: AppBar(title: Text(t), actions: [IconButton(icon: const Icon(Icons.delete), onPressed: (){})]), body: const Center(child: Text("Kosong")))));
  Widget _card(List<Widget> i) => Container(margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Column(children: i));
  Widget _item(IconData i, String t, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i), title: Text(t), trailing: const Icon(Icons.chevron_right, size: 16)));
}
