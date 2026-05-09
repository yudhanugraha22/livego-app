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

  @override void initState() { super.initState(); _fetch(); }

  _fetch() async {
    setState(() => isLoading = true);
    final res = await ApiService.get("/api/v2/home?category_p=${selectedPlatform.toLowerCase()}&lang=id");
    if (res != null) setState(() { dramas = res['data']; isLoading = false; });
  }

  @override Widget build(BuildContext context) {
    bool isTV = MediaQuery.of(context).size.width > 900;
    List<String> plats = ["Melolo", "FreeReels", "FlickReels", "RapidTV"];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(backgroundColor: const Color(0xFF161B22), elevation: 0, title: const Text("Livego", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
      body: Column(children: [
        const SizedBox(height: 10),
        SizedBox(height: 50, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: plats.length, itemBuilder: (c, i) => Padding(padding: const EdgeInsets.only(right: 8), child: TVButton(borderRadius: 25, onTap: () { selectedPlatform = plats[i]; _fetch(); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 25), alignment: Alignment.center, decoration: BoxDecoration(color: selectedPlatform == plats[i] ? const Color(0xFF8B5CF6) : Colors.white10, borderRadius: BorderRadius.circular(25)), child: Text(plats[i])))))),
        Expanded(child: isLoading ? const Center(child: CircularProgressIndicator()) : GridView.builder(padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isTV ? 7 : 4, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: dramas.length, itemBuilder: (c, i) => TVButton(onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (c) => DetailPage(id: dramas[i]['id'], source: selectedPlatform.toLowerCase())));
        }, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(dramas[i]['cover'], fit: BoxFit.cover))), const SizedBox(height: 4), Text(dramas[i]['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10))]))))
      ]),
    );
  }
}
