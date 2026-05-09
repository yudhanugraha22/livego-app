import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';
import 'api_service.dart';
import 'player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List ds = []; Map? banner; bool load = true; 
  String selectedPlatform = "melolo"; 
  String selectedCategory = "Dubbing";
  List<String> activeApis = [];

  @override void initState() { super.initState(); _init(); }

  _init() async {
    final p = await SharedPreferences.getInstance();
    final List<String> all = ["Melolo","FreeReels","FlickReels","RapidTV"];
    setState(() {
      activeApis = all.where((a)=>p.getBool('api_$a')??true).toList();
      if (activeApis.isNotEmpty) selectedPlatform = activeApis[0].toLowerCase();
    });
    _fetch();
  }

  _fetch() async {
    setState(() => load = true);
    // Jalur Banner
    final bRes = await ApiService.get("/api/v2/banner?category_p=$selectedPlatform&lang=id");
    if (bRes != null && bRes['data'].isNotEmpty) banner = bRes['data'][0];

    // Jalur List Film (Fix Logika Dubbing)
    String p = (selectedCategory == "Dubbing") 
      ? "/api/v2/search?category_p=$selectedPlatform&q=sulih suara&lang=id" 
      : "/api/v2/home?category_p=$selectedPlatform&lang=id";
    
    final res = await ApiService.get(p);
    setState(() {
      if (res != null) ds = res['data'];
      load = false; // Memastikan loading berhenti
    });
  }

  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text("Livego", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(child: Column(children: [
        if (banner != null) _buildBanner(),
        _buildList(activeApis, selectedPlatform, (v){ setState(()=>selectedPlatform=v.toLowerCase()); _fetch(); }, const Color(0xFF8B5CF6)),
        const SizedBox(height: 8),
        _buildList(["Dubbing","Populer","New","Trending"], selectedCategory, (v){ setState(()=>selectedCategory=v); _fetch(); }, Colors.blueAccent),
        const SizedBox(height: 10),
        load ? const Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: Colors.blueAccent)) : _buildGrid(isT),
      ])),
    );
  }

  Widget _buildBanner() => Container(height: 180, margin: const EdgeInsets.all(15), child: TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (c)=>PlayerPage(id: banner!['id'], source: selectedPlatform, title: banner!['title']))), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(banner!['cover'], fit: BoxFit.cover, width: double.infinity)), Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black, Colors.transparent])), padding: const EdgeInsets.all(15), alignment: Alignment.bottomLeft, child: Text(banner!['title'], style: const TextStyle(fontWeight: FontWeight.bold)))])));

  Widget _buildList(List l, String s, Function(String) o, Color c) => SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: l.length, itemBuilder: (ctx, i)=>Padding(padding: const EdgeInsets.only(right: 8), child: TVButton(onTap: ()=>o(l[i]), child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), alignment: Alignment.center, decoration: BoxDecoration(color: s.toLowerCase() == l[i].toLowerCase() || s == l[i] ? c : Colors.white10, borderRadius: BorderRadius.circular(25)), child: Text(l[i]))))));

  Widget _buildGrid(bool isT) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isT?7:4, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: ds.length, itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c)=>PlayerPage(id: ds[i]['id'], source: selectedPlatform, title: ds[i]['title']))), child: Column(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(ds[i]['cover'], fit: BoxFit.cover))), Text(ds[i]['title'], maxLines:1, style: const TextStyle(fontSize: 9))])));
}
