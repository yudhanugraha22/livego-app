import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<String> favorites = [];
  List<String> history = [];

  @override void initState() { super.initState(); _loadData(); }

  _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      favorites = p.getStringList('livego_favs') ?? [];
      history = p.getStringList('livego_history') ?? [];
    });
  }
  _loadData() => _load();

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        const SizedBox(height: 50),
        _header(),
        const SizedBox(height: 25),
        _label("KOLEKSI CEPAT"),
        _card([
          _item(context, Icons.history, "Riwayat", "${history.length} Judul", () => _goList("Riwayat", history)),
          _item(context, Icons.favorite, "Favorit", "${favorites.length} Judul", () => _goList("Favorit", favorites)),
        ]),
        _label("PENGATURAN SYSTEM"),
        _card([
          _item(context, Icons.settings, "Navigasi", "Otomatis", (){}),
          _item(Icons.lock, "Widevine DRM", "Auto", (){}),
        ]),
      ]),
    );
  }

  void _goList(String t, List<String> items) {
    Navigator.push(context, MaterialPageRoute(builder: (c) => ListDataPage(title: t, items: items)));
  }

  Widget _header() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: const Row(children: [CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.person, color: Colors.white)), SizedBox(width: 15), Text("User Penggemar", style: TextStyle(fontWeight: FontWeight.bold))]));
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)));
  Widget _card(List<Widget> i) => Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.only(bottom: 20), child: Column(children: i));
  Widget _item(BuildContext ctx, IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right, size: 16)));
}

class ListDataPage extends StatefulWidget {
  final String title; final List<String> items;
  const ListDataPage({super.key, required this.title, required this.items});
  @override State<ListDataPage> createState() => _ListDataPageState();
}

class _ListDataPageState extends State<ListDataPage> {
  late List<String> currentItems;
  @override void initState() { super.initState(); currentItems = List.from(widget.items); }

  _delete(int i) async {
    final p = await SharedPreferences.getInstance();
    setState(() { currentItems.removeAt(i); });
    String key = widget.title == "Favorit" ? 'livego_favs' : 'livego_history';
    await p.setStringList(key, currentItems);
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: const Color(0xFF161B22)),
      body: currentItems.isEmpty ? const Center(child: Text("Kosong")) : ListView.builder(
        itemCount: currentItems.length,
        itemBuilder: (c, i) => ListTile(title: Text(currentItems[i]), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(i))),
      ),
    );
  }
}
