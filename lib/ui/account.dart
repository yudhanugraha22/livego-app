import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        const SizedBox(height: 50),
        _header(),
        const SizedBox(height: 25),
        _label("KOLEKSI"),
        _card([
          _item(context, Icons.history, "Riwayat", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryPage()))),
          _item(context, Icons.favorite, "Favorit", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FavoritePage()))),
        ]),
      ]),
    );
  }
  Widget _header() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: const Row(children: [CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.person, color: Colors.white)), SizedBox(width: 15), Text("User Penggemar", style: TextStyle(fontWeight: FontWeight.bold))]));
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey)));
  Widget _card(List<Widget> i) => Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Column(children: i));
  Widget _item(IconData i, String t, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t), trailing: const Icon(Icons.chevron_right, size: 16)));
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Riwayat")), body: const Center(child: Text("Belum ada riwayat")));
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Favorit")), body: const Center(child: Text("Belum ada favorit")));
  }
}
