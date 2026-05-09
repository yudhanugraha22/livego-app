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
  List dramas = [];
  Map? bannerData;
  bool isLoading = true;
  String selectedPlatform = 'Melolo';
  String selectedCategory = 'Dubbing'; 

  final List<String> platforms = ["Melolo", "FreeReels", "FlickReels", "RapidTV"];
  final List<String> categories = ["Dubbing", "Populer", "New", "Trending", "Segera Hadir"];

  @override
  void initState() { super.initState(); _fetchAllData(); }

  _fetchAllData() async {
    setState(() { isLoading = true; });
    final bannerRes = await ApiService.get("/api/v2/banner?category_p=${selectedPlatform.toLowerCase()}&lang=id");
    if (bannerRes != null && bannerRes['success'] == true && bannerRes['data'].isNotEmpty) {
      setState(() { bannerData = bannerRes['data'][0]; });
    }
    String path = (selectedCategory == "Dubbing")
        ? "/api/v2/search?category_p=${selectedPlatform.toLowerCase()}&q=sulih suara&lang=id"
        : "/api/v2/home?category_p=${selectedPlatform.toLowerCase()}&lang=id";
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
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: const Text("Livego", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryPage()))),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FavoritePage()))),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          _buildBanner(),
          const Divider(color: Colors.white10, thickness: 1, indent: 15, endIndent: 15),
          _buildHList(platforms, selectedPlatform, (v) { setState(() => selectedPlatform = v); _fetchAllData(); }, const Color(0xFF8B5CF6)),
          const SizedBox(height: 10),
          _buildHList(categories, selectedCategory, (v) { setState(() => selectedCategory = v); _fetchAllData(); }, Colors.blueAccent),
          const SizedBox(height: 15),
          isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent)) : _buildGrid(isTV),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }

  Widget _buildBanner() {
    if (bannerData == null) return const SizedBox(height: 200);
    return Container(
      margin: const EdgeInsets.all(15), height: 200,
      child: TVButton(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DetailPage(id: bannerData!['id'], source: selectedPlatform.toLowerCase()))),
        child: Stack(children: [
          ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(bannerData!['cover'], fit: BoxFit.cover, width: double.infinity)),
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.9), Colors.transparent]))),
          Padding(padding: const EdgeInsets.all(15), child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(bannerData!['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(bannerData!['synopsis'] ?? "", maxLines: 2, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ])),
        ]),
      ),
    );
  }

  Widget _buildHList(List<String> list, String selected, Function(String) onSel, Color color) => SizedBox(height: 42, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 15), itemCount: list.length, itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.only(right: 10), child: TVButton(borderRadius: 25, onTap: () => onSel(list[i]), child: Container(padding: const EdgeInsets.symmetric(horizontal: 25), alignment: Alignment.center, decoration: BoxDecoration(color: selected == list[i] ? color : Colors.white10, borderRadius: BorderRadius.circular(25)), child: Text(list[i], style: const TextStyle(fontSize: 12)))))));

  Widget _buildGrid(bool isTV) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isTV ? 7 : 4, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: dramas.length, itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DetailPage(id: dramas[i]['id'], source: selectedPlatform.toLowerCase()))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(dramas[i]['cover'], fit: BoxFit.cover, width: double.infinity))), const SizedBox(height: 5), Text(dramas[i]['title'], maxLines: 1, style: const TextStyle(fontSize: 9))])));
}
