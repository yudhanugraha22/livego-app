import 'package:flutter/material.dart';
import 'widgets.dart';
import 'player.dart';
import 'api_service.dart';
import 'account.dart'; // Untuk navigasi riwayat/favorit

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List dramas = [];
  Map? bannerData;
  bool isLoading = true;
  
  String selectedPlatform = 'melolo';
  String selectedCategory = 'Dubbing'; // Default Dubbing

  final List<String> platforms = ["Melolo", "FreeReels", "FlickReels", "RapidTV"];
  // Urutan Dubbing Paling Depan
  final List<String> categories = ["Dubbing", "Populer", "New", "Trending", "Segera Hadir"];

  @override
  void initState() { super.initState(); _fetchAllData(); }

  _fetchAllData() async {
    setState(() { isLoading = true; });
    
    // 1. Ambil Banner
    final bannerRes = await ApiService.get("/api/v2/banner?category_p=${selectedPlatform.toLowerCase()}&lang=id");
    if (bannerRes != null && bannerRes['success'] == true && bannerRes['data'].isNotEmpty) {
      setState(() { bannerData = bannerRes['data'][0]; });
    }

    // 2. Ambil List Drama dengan Logika Filter
    String path;
    if (selectedCategory == "Dubbing") {
      // Jika Dubbing, kita tembak API Search otomatis
      path = "/api/v2/search?category_p=${selectedPlatform.toLowerCase()}&q=sulih suara&lang=id";
    } else {
      path = "/api/v2/home?category_p=${selectedPlatform.toLowerCase()}&lang=id";
    }

    final res = await ApiService.get(path);
    if (res != null && res['success'] == true) {
      setState(() { dramas = res['data']; isLoading = false; });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTV = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: const Text("Livego", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.blueAccent)),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryPage()))),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FavoritePage()))),
          IconButton(icon: const Icon(Icons.search), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchPage()))),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDynamicBanner(),
            const Divider(color: Colors.white10, thickness: 1, indent: 15, endIndent: 15),
            _buildHorizontalList(platforms, selectedPlatform, (v) { setState(() => selectedPlatform = v); _fetchAllData(); }, const Color(0xFF8B5CF6)),
            const SizedBox(height: 10),
            _buildHorizontalList(categories, selectedCategory, (v) { setState(() => selectedCategory = v); _fetchAllData(); }, Colors.blueAccent),
            const SizedBox(height: 15),
            isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent)) : _buildGrid(isTV),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicBanner() {
    if (bannerData == null) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    return Container(
      margin: const EdgeInsets.all(15), height: 210,
      child: TVButton(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DetailPage(id: bannerData!['id'], source: selectedPlatform.toLowerCase()))),
        child: Stack(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.network(bannerData!['cover'], fit: BoxFit.cover, width: double.infinity)),
            Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.9), Colors.transparent]))),
            Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(bannerData!['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(bannerData!['synopsis'] ?? "", maxLines: 2, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<String> list, String selected, Function(String) onSel, Color color) {
    return SizedBox(height: 42, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 15), itemCount: list.length, itemBuilder: (context, i) => Padding(padding: const EdgeInsets.only(right: 10), child: TVButton(borderRadius: 25, onTap: () => onSel(list[i]), child: Container(padding: const EdgeInsets.symmetric(horizontal: 25), alignment: Alignment.center, decoration: BoxDecoration(color: selected == list[i] ? color : Colors.white10, borderRadius: BorderRadius.circular(25)), child: Text(list[i], style: const TextStyle(fontSize: 12)))))));
  }

  Widget _buildGrid(bool isTV) {
    return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isTV ? 7 : 4, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: dramas.length, itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DetailPage(id: dramas[i]['id'], source: selectedPlatform.toLowerCase()))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(dramas[i]['cover'], fit: BoxFit.cover, width: double.infinity))), const SizedBox(height: 5), Text(dramas[i]['title'], maxLines: 1, style: const TextStyle(fontSize: 9))])));
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const TextField(autofocus: true, decoration: InputDecoration(hintText: "Cari Dracin Dubbing...", border: InputBorder.none))), body: const Center(child: Text("Hasil Pencarian")));
  }
}
