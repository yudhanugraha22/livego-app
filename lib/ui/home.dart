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
  bool isLoading = true;
  String selectedPlatform = 'Melolo';
  String selectedSub = 'Home';

  // Sesuai permintaan: Tetap 4 Platform
  final List<String> platforms = ["Melolo", "FreeReels", "FlickReels", "RapidTV"];

  @override
  void initState() { super.initState(); _fetch(); }

  _fetch() async {
    setState(() => isLoading = true);
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
            // 1. BANNER MEWAH STYLE CINEFLOW
            _buildLargeBanner(),

            const SizedBox(height: 10),
            
            // 2. BORDER DI ATAS PLATFORM
            const Divider(color: Colors.white10, thickness: 1, indent: 15, endIndent: 15),

            // 3. DAFTAR 4 PLATFORM (UNGU)
            _buildPlatformList(),

            const SizedBox(height: 10),

            // 4. SUB-KATEGORI (BIRU)
            _buildSubCategory(),

            const SizedBox(height: 15),

            // 5. GRID FILM DENGAN BADGE
            isLoading 
              ? const Padding(padding: EdgeInsets.all(50), child: Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))))
              : _buildGrid(isTV),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeBanner() {
    return Container(
      margin: const EdgeInsets.all(15),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: const Color(0xFF161B22),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          // Background Image dengan Blur/Gradient
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.network(
              "https://via.placeholder.com/800x400/1e293b/ffffff?text=Background",
              fit: BoxFit.cover, width: double.infinity,
            ),
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
          // Konten Teks
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
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(5)),
                        child: Text(selectedPlatform.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      const Text("Menikahi Ayah Mantanku", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      const Text("Saat memergoki pacarnya berselingkuh, Clarissa melampiaskan amarahnya...", 
                        maxLines: 2, style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                // Gambar Kecil di Kanan (Floating Poster)
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network("https://via.placeholder.com/100x150", fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformList() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: platforms.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: TVButton(
            borderRadius: 20,
            onTap: () { setState(() => selectedPlatform = platforms[i]); _fetch(); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectedPlatform == platforms[i] ? const Color(0xFF8B5CF6) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(platforms[i], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategory() {
    List<String> subs = ["${selectedPlatform} Home", "Jelajah"];
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: subs.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: TVButton(
            borderRadius: 15,
            onTap: () => setState(() => selectedSub = subs[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: selectedSub == subs[i] 
                  ? const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)]) 
                  : null,
                color: selectedSub == subs[i] ? null : Colors.white10,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(subs[i], style: const TextStyle(fontSize: 11)),
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
                    // Pojok Kiri Atas: EP
                    Positioned(
                      top: 5, left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                        child: Text("${dramas[i]['chapters'] ?? '1'} Ep", style: const TextStyle(fontSize: 7)),
                      ),
                    ),
                    // Pojok Kanan Atas: VIEWS
                    Positioned(
                      top: 5, right: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                        child: Text(dramas[i]['views'] ?? '0', style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold)),
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
