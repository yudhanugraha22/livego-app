import 'package:flutter/material.dart';
import 'widgets.dart';
import 'player.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List dramas = []; bool isLoading = true;
  String selectedPlatform = 'melolo';
  // Hanya platform yang ada di plan Anda
  final List<String> plats = ["Melolo", "FreeReels", "FlickReels", "RapidTV"];

  @override void initState() { super.initState(); _fetch(); }

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

  @override Widget build(BuildContext context) {
    bool isTV = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text("Livego", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
      body: Column(children: [
        SizedBox(height: 50, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: plats.length, itemBuilder: (c, i) => Padding(padding: const EdgeInsets.only(right: 8), child: TVButton(onTap: () { setState(() { selectedPlatform = plats[i]; }); _fetch(); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), alignment: Alignment.center, decoration: BoxDecoration(color: selectedPlatform == plats[i] ? const Color(0xFF8B5CF6) : Colors.white10, borderRadius: BorderRadius.circular(20)), child: Text(plats[i])))))),
        Expanded(child: isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent)) : GridView.builder(padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isTV ? 7 : 4, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: dramas.length, itemBuilder: (c, i) => TVButton(onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (c) => DetailPage(id: dramas[i]['id'], source: selectedPlatform.toLowerCase())));
        }, child: Column(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(dramas[i]['cover'], fit: BoxFit.cover))), const SizedBox(height: 4), Text(dramas[i]['title'], maxLines: 1, style: const TextStyle(fontSize: 10))]))))
      ]),
    );
  }
}
