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
  List ds = []; bool load = true; String selS = "melolo"; List<String> activeApis = [];
  @override void initState() { super.initState(); _init(); }
  _init() async {
    final p = await SharedPreferences.getInstance();
    final List<String> all = ["Melolo", "DramaBox", "Netshort", "Goodshort", "Shortmax", "DramaWave", "FlickReels", "FreeReels", "RapidTV"];
    setState(() {
      activeApis = all.where((api) => p.getBool('api_$api') ?? ["Melolo", "FreeReels", "FlickReels", "RapidTV"].contains(api)).toList();
      if (activeApis.isNotEmpty) selS = activeApis[0].toLowerCase();
    });
    _fetch();
  }
  _fetch() async {
    setState(()=>load=true);
    final res = await ApiService.get("/api/v2/home?category_p=$selS&lang=id");
    if (res != null) setState((){ ds = res['data']; load = false; });
    else setState(()=>load=false);
  }
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(backgroundColor: const Color(0xFF0D1117), appBar: AppBar(backgroundColor: const Color(0xFF161B22), elevation: 0, title: const Text("Livego", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))), body: Column(children: [
      SizedBox(height: 50, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: activeApis.length, itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.only(right: 10), child: TVButton(borderRadius: 25, onTap: (){ selS=activeApis[i].toLowerCase(); _fetch(); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 25), alignment: Alignment.center, decoration: BoxDecoration(color: selS == activeApis[i].toLowerCase() ? const Color(0xFF8B5CF6) : Colors.white10, borderRadius: BorderRadius.circular(25)), child: Text(activeApis[i])))))),
      Expanded(child: load ? const Center(child: CircularProgressIndicator()) : GridView.builder(padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isT?7:4, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: ds.length, itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c)=>PlayerPage(id: ds[i]['id'], source: selS, title: ds[i]['title']))), child: Column(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(ds[i]['cover'], fit: BoxFit.cover))), Text(ds[i]['title'], maxLines:1, style: const TextStyle(fontSize: 9))]))))
    ]));
  }
}
