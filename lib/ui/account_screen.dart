import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared/widgets.dart';
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override State<AccountScreen> createState() => _AccountScreenState();
}
class _AccountScreenState extends State<AccountScreen> {
  String nav = "Otomatis"; bool cache = true;
  @override void initState() { super.initState(); _L(); }
  _L() async { final p = await SharedPreferences.getInstance(); setState(() { nav = p.getString('navType') ?? "Otomatis"; }); }
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF05070D), body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: const Color(0xFF161B22)), child: Row(children: [const CircleAvatar(radius: 30, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white)), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("User Penggemar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("LiveGo Premium", style: TextStyle(color: Color(0xFF00D9FF), fontSize: 12))])])),
      const SizedBox(height: 25),
      _g("PENGATURAN SYSTEM", [ _i(Icons.settings, "Navigasi", nav), _i(Icons.lock, "Widevine DRM", "Paksa L3"), _i(Icons.layers, "Sumber Data", "24 API") ]),
      _g("KOLEKSI", [ _i(Icons.history, "Riwayat", "Paten"), _i(Icons.favorite, "Favorit", "Paten") ]),
    ]));
  }
  Widget _g(String t, List<Widget> i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 10, bottom: 10), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))), Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(24)), margin: const EdgeInsets.only(bottom: 25), child: Column(children: i))]);
  Widget _i(IconData i, String t, String s) => TVButton(onTap: (){}, child: ListTile(leading: Icon(i, color: const Color(0xFF00D9FF)), title: Text(t), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right)));
}
