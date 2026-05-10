import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api.dart';
import 'widgets.dart';
import 'player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List ds = []; Map? banner; bool load = true;
  String selS = "melolo"; String selC = "Dubbing";
  List<String> activeApis = [];

  @override void initState() { super.initState(); _init(); }
  _init() async {
    final p = await SharedPreferences.getInstance();
    final List<String> all = ["Melolo","FreeReels","FlickReels","RapidTV","DramaBox","Netshort","Goodshort","iDrama"];
    setState(() { activeApis = all.where((a)=>p.getBool('api_$a')??["Melolo","FreeReels","FlickReels","RapidTV"].contains(a)).toList(); });
    _fetch();
  }
  _fetch() async {
    setState(()=>load=true);
    final bRes = await LiveApi.fetch("/api/v2/banner?category_p=$selS&lang=id");
    if (bRes != null && bRes['data'].isNotEmpty) banner = bRes['data'][0];

    String p = (selC == "Dubbing") ? "/api/v2/search?category_p=$selS&q=sulih suara&lang=id" : "/api/v2/home?category_p=$selS&lang=id";
    final res = await LiveApi.fetch(p);
    setState(() { if (res != null) ds = res['data']; load = false; });
  }

  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(backgroundColor: const Color(0xFF0D1117), appBar: AppBar(backgroundColor: const Color(0xFF161B22), title: const Text("Livego", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(child: Column(children: [
        if (banner != null) _bannerUI(),
        _chip(activeApis, selS, (v){ selS=v.toLowerCase(); _fetch(); }, const Color(0xFF8B5CF6)),
        const SizedBox(height: 10),
        _chip(["Dubbing","Populer","New","Trending"], selC, (v){ selC=v; _fetch(); }, Colors.blueAccent),
        load ? const Center(child: CircularProgressIndicator()) : _grid(isT),
      ])),
    );
  }
  Widget _bannerUI() => Container(height: 200, margin: const EdgeInsets.all(15), child: TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (c)=>PlayerPage(id: banner!['id'], source: selS, title: banner!['title']))), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(banner!['cover'], fit: BoxFit.cover, width: double.infinity)), Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black, Colors.transparent])), padding: const EdgeInsets.all(20), alignment: Alignment.bottomLeft, child: Text(banner!['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))])));
  Widget _chip(List l, String s, Function(String) o, Color c) => SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: l.length, itemBuilder: (ctx, i)=>Padding(padding: const EdgeInsets.only(right: 10), child: TVButton(onTap: ()=>o(l[i]), child: Container(padding: const EdgeInsets.symmetric(horizontal: 25), alignment: Alignment.center, decoration: BoxDecoration(color: s.toLowerCase() == l[i].toLowerCase() || s == l[i] ? c : Colors.white10, borderRadius: BorderRadius.circular(25)), child: Text(l[i], style: const TextStyle(fontSize: 12)))))));
  Widget _grid(bool isT) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isT?7:4, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: ds.length, itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c)=>PlayerPage(id: ds[i]['id'], source: selS, title: ds[i]['title']))), child: Column(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(ds[i]['cover'], fit: BoxFit.cover))), Text(ds[i]['title'], maxLines:1, style: const TextStyle(fontSize: 9))])));
}
