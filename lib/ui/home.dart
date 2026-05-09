import 'package:flutter/material.dart';
import 'widgets.dart';
import 'player.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List dramas = [];
  Map? bannerData; // Data banner asli dari API
  bool isLoading = true;
  bool isBannerLoading = true;
  
  String selectedPlatform = 'melolo';
  String selectedCategory = 'Populer';

  final List<String> platforms = ["Melolo", "FreeReels", "FlickReels", "RapidTV"];
  // Kategori sesuai keinginan Anda
  final List<String> categories = ["Populer", "New", "Trending", "Dubbing", "Segera Hadir"];

  @override
  void initState() { 
    super.initState(); 
    _fetchAllData(); 
  }

  // Fungsi ambil Banner & List Film sekaligus
  _fetchAllData() async {
    setState(() { isLoading = true; isBannerLoading = true; });
    
    // 1. Ambil Banner
    final bannerRes = await ApiService.get("/api/v2/banner?category_p=${selectedPlatform.toLowerCase()}&lang=id");
    if (bannerRes != null && bannerRes['success'] == true && bannerRes['data'].isNotEmpty) {
      setState(() { bannerData = bannerRes['data'][0]; isBannerLoading = false; });
    } else {
      setState(() => isBannerLoading = false);
    }

    // 2. Ambil List Drama
    final path = "/api/v2/home?category_p=${selectedPlatform.toLowerCase()}&lang=id";
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
        title: const Text("CineFlow", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // BANNER DINAMIS DARI API
            _buildDynamicBanner(),

            const SizedBox(height: 5),
            const Divider(color: Colors.white10, thickness: 1, indent: 15, endIndent: 15),

            // BARIS 1: PLATFORM (UNGU)
            _buildHorizontalList(platforms, selectedPlatform, (val) {
              setState(() { selectedPlatform = val; });
              _fetchAllData(); // Reload semua data saat ganti platform
            }, const Color(0xFF8B5CF6)),

            const SizedBox(height: 10),

            // BARIS 2: KATEGORI (BIRU)
            _buildHorizontalList(categories, selectedCategory, (val) {
              setState(() { selectedCategory = val; });
              _fetchAllData(); // Simulasi filter
            }, Colors.blueAccent),

            const SizedBox(height: 15),

            // GRID FILM
            isLoading 
              ? const Padding(padding: EdgeInsets.all(50), child: Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))))
              : _buildGrid(isTV),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicBanner() {
    if (isBannerLoading) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    if (bannerData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(15),
      height: 210,
      child: TVButton(
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (c) => DetailPage(id: bannerData!['id'], source: selectedPlatform.toLowerCase())));
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(bannerData!['cover'], fit: BoxFit.cover, width: double.infinity),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.centerRight, end: Alignment.centerLeft,
                  colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.9)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(5)),
                          child: Text(selectedPlatform.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 10),
                        Text(bannerData!['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2),
                        const SizedBox(height: 5),
                        Text(bannerData!['synopsis'] ?? "", maxLines: 2, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(bannerData!['cover'], fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<String> list, String selected, Function(String) onSel, Color color) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: list.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: TVButton(
            borderRadius: 25,
            onTap: () => onSel(list[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected == list[i] ? color : Colors.white10,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(list[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(bool isTV) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTV ? 7 : 4,
        childAspectRatio: 0.62,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: dramas.length,
      itemBuilder: (c, i) => TVButton(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (c) => DetailPage(id: dramas[i]['id'], source: selectedPlatform.toLowerCase())));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(dramas[i]['cover'], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    Positioned(
                      top: 5, left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                        child: Text("${dramas[i]['chapters'] ?? '1'} Ep", style: const TextStyle(fontSize: 7)),
                      ),
                    ),
                    Positioned(
                      top: 5, right: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                        child: Text(dramas[i]['views'] ?? '0', style: const TextStyle(fontSize: 7)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(dramas[i]['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
