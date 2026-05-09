import 'package:flutter/material.dart';
import 'widgets.dart';
import 'player.dart';
import 'api_service.dart';
import 'account.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List dramas = []; bool isLoading = true;
  String selectedPlatform = 'melolo';
  final List<String> platforms = ["Melolo", "FreeReels", "FlickReels", "RapidTV"];

  @override void initState() { super.initState(); _fetch(); }

  _fetch() async {
    setState(() => isLoading = true);
    final res = await ApiService.get("/api/v2/home?category_p=${selectedPlatform.toLowerCase()}&lang=id");
    if (res != null) setState(() { dramas = res['data']; isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    bool isTV = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        centerTitle: false, // Menghilangkan teks Cineflow di pojok kiri
        title: const Text("Livego", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryPage()))),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FavoritePage()))),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        const SizedBox(height: 10),
        SizedBox(height: 50, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: platforms.length, itemBuilder: (c, i) => Padding(padding: const EdgeInsets.only(right: 8), child: TVButton(onTap: () { setState(() => selectedPlatform = platforms[i]); _fetch(); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), alignment: Alignment.center, decoration: BoxDecoration(color: selectedPlatform == platforms[i] ? const Color(0xFF8B5CF6) : Colors.white10, borderRadius: BorderRadius.circular(20)), child: Text(platforms[i])))))),
        Expanded(child: isLoading ? const Center(child: CircularProgressIndicator()) : GridView.builder(padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isTV ? 7 : 4, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: dramas.length, itemBuilder: (c, i) => TVButton(onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (c) => DetailPage(id: dramas[i]['id'], source: selectedPlatform.toLowerCase())));
        }, child: Column(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(dramas[i]['cover'], fit: BoxFit.cover))), Text(dramas[i]['title'], maxLines: 1, style: const TextStyle(fontSize: 10))]))))
      ]),
    );
  }
}
