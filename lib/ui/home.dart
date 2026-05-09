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
  String selectedPlatform = 'melolo';
  String selectedCategory = 'Populer';

  // 4 Platform sesuai Plan Anda
  final List<String> platforms = ["Melolo", "FreeReels", "FlickReels", "RapidTV"];
  final List<String> categories = ["Populer", "New", "Segera Hadir", "Dubbing", "Trend"];

  @override
  void initState() { super.initState(); _fetch(); }

  _fetch() async {
    setState(() => isLoading = true);
    // Path API tetap menggunakan category_p dari platform yang dipilih
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
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: const Text("Livego", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            
            // 1. BANNER MEWAH (CINEFLOW STYLE)
            _buildBanner(),

            const SizedBox(height: 15),

            // 2. BARIS PLATFORM (UNGU)
            _buildHorizontalList(platforms, selectedPlatform, (val) {
              setState(() { selectedPlatform = val; });
              _fetch();
            }, const Color(0xFF8B5CF6)),

            const SizedBox(height: 10),

            // 3. BARIS KATEGORI (BIRU)
            _buildHorizontalList(categories, selectedCategory, (val) {
              setState(() { selectedCategory = val; });
              // Anda bisa menambahkan filter category_p di sini jika API mendukung
            }, Colors.blueAccent),

            const SizedBox(height: 15),

            // 4. GRID KONTEN
            isLoading 
              ? const Padding(padding: EdgeInsets.all(50), child: Center(child: CircularProgressIndicator(color: Colors.blueAccent)))
              : _buildGrid(isTV),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: TVButton(
        onTap: () {},
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: NetworkImage("https://via.placeholder.com/800x400/1e293b/ffffff?text=Feature+Drama+Promo"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.9), Colors.transparent],
              ),
            ),
            alignment: Alignment.bottomLeft,
            child: Text(
              "Hot Drama di $selectedPlatform",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
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
              child: Text(
                list[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected == list[i] ? FontWeight.bold : FontWeight.normal,
                ),
              ),
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
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
                    // Badge Episode (Contoh)
                    Positioned(
                      top: 5, left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                        child: const Text("HD", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dramas[i]['title'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
