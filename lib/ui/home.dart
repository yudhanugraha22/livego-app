import 'package:flutter/material.dart';
import 'widgets.dart';
import 'player.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List dramas = []; bool loading = true;
  String selectedPlatform = 'Melolo';
  String selectedCategory = 'Dubbing'; 
  final List<String> platforms = ["Melolo", "FreeReels", "FlickReels", "RapidTV"];
  final List<String> categories = ["Dubbing", "Populer", "New", "Trending"];

  @override void initState() { super.initState(); _fetch(); }

  _fetch() async {
    setState(() => loading = true);
    final path = "/api/v2/home?category_p=${selectedPlatform.toLowerCase()}&lang=id";
    final res = await ApiService.get(path);
    if (res != null) setState(() { dramas = res['data']; loading = false; });
  }

  @override Widget build(BuildContext context) {
    bool isTV = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(backgroundColor: const Color(0xFF161B22), elevation: 0, title: const Text("Livego", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
      body: SingleChildScrollView(child: Column(children: [
        const SizedBox(height: 10),
        _buildList(platforms, selectedPlatform, (v) { setState(()=>selectedPlatform=v); _fetch(); }, const Color(0xFF8B5CF6)),
        const SizedBox(height: 8),
        _buildList(categories, selectedCategory, (v) { setState(()=>selectedCategory=v); _fetch(); }, Colors.blueAccent),
        loading ? const Center(child: CircularProgressIndicator()) : GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isTV ? 7 : 4, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: dramas.length, itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => DetailPage(id: dramas[i]['id'], source: selectedPlatform.toLowerCase()))), child: Column(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(dramas[i]['cover'], fit: BoxFit.cover))), Text(dramas[i]['title'], maxLines: 1, style: const TextStyle(fontSize: 9))]))),
      ])),
    );
  }

  Widget _buildList(List<String> l, String s, Function(String) o, Color c) => SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: l.length, itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.only(right: 10), child: TVButton(borderRadius: 25, onTap: () => o(l[i]), child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), alignment: Alignment.center, decoration: BoxDecoration(color: s == l[i] ? c : Colors.white10, borderRadius: BorderRadius.circular(25)), child: Text(l[i]))))));
}
