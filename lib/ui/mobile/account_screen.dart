import 'package:flutter/material.dart';
import '../shared/widgets.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF05070D), body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF161B22), Color(0xFF05070D)])), child: Row(children: [const CircleAvatar(radius: 35, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white, size: 40)), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("User Penggemar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text("LiveGo Premium", style: TextStyle(color: Color(0xFF00D9FF), fontSize: 13))])])),
      const SizedBox(height: 25),
      _group("PENGATURAN SYSTEM", [ _item(Icons.settings, "Navigasi Hardware", "Otomatis"), _item(Icons.lock, "Widevine DRM", "Auto"), _item(Icons.layers, "Kelola Sumber Data", "24 API") ]),
      _group("KOLEKSI CEPAT", [ _item(Icons.history, "Riwayat Tontonan", "Paten"), _item(Icons.favorite, "Drama Favorit", "Paten") ]),
    ]));
  }
  Widget _group(String t, List<Widget> i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 10, bottom: 10), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))), Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(24)), margin: const EdgeInsets.only(bottom: 25), child: Column(children: i))]);
  Widget _item(IconData i, String t, String s) => TVButton(onTap: (){}, child: ListTile(leading: Icon(i, color: const Color(0xFF00D9FF)), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(s, style: const TextStyle(fontSize: 11)), trailing: const Icon(Icons.chevron_right)));
}
