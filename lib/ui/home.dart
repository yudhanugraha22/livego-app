import 'package:flutter/material.dart';
import 'widgets.dart';
import 'player.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List ds = []; Map? banner; bool loading = true;
  String selS = "melolo"; String selC = "Dubbing";
  final List<String> platforms = ["Melolo", "FreeReels", "FlickReels", "RapidTV"];
  final List<String> categories = ["Dubbing", "Populer", "New", "Trending"];

  @override void initState() { super.initState(); fetch(); }

  fetch() async {
    setState(() => loading = true);
    final bRes = await ApiService.get("/api/v2/banner?category_p=$selS&lang=id");
    if (bRes != null && bRes['data'].isNotEmpty) banner = bRes['data'][0];

    String p = (selC == "Dubbing") ? "/api/v2/search?category_p=$selS&q=sulih suara&lang=id" : "/api/v2/home?category_p=$selS&lang=id";
    final r = await ApiService.get(p);
    if (r != null) setState(() { ds = r['data']; loading = false; });
    else setState(() => loading = false);
  }

  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(backgroundColor: const Color(0xFF161B22), elevation: 0, title: const Text("Livego", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
      body: SingleChildScrollView(child: Column(children: [
        if (banner != null) Container(margin: const EdgeInsets.all(15), height: 180, child: TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c)=>PlayerPage(id: banner!['id'], source: selS, title: banner!['title']))), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(banner!['cover'], fit: BoxFit.cover, width: double.infinity)), Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black, Colors.transparent])), padding: const EdgeInsets.all(15), alignment: Alignment.bottomLeft, child: Text(banner!['title'], style: const TextStyle(fontWeight: FontWeight.bold)))]))),
        _list(platforms, selS, (v){ setState(()=>selS=v.toLowerCase()); fetch(); }, const Color(0xFF8B5CF6)),
        const SizedBox(height: 10),
        _list(cats, selC, (v){ setState(()=>selC=v); fetch(); }, Colors.blueAccent),
        loading ? const Center(child: CircularProgressIndicator()) : GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isT?7:4, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: ds.length, itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => PlayerPage(id: ds[i]['id'], source: selS, title: ds[i]['title']))), child: Column(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(ds[i]['cover'], fit: BoxFit.cover))), Text(ds[i]['title'], maxLines:1, style: const TextStyle(fontSize: 10))]))),
      ])),
    );
  }
  final List<String> cats = ["Dubbing", "Populer", "New", "Trending"];
  Widget _list(List l, String s, Function(String) o, Color c) => SizedBox(height: 40, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: l.length, itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.only(right: 10), child: TVButton(borderRadius: 25, onTap: () => o(l[i]), child: Container(padding: const EdgeInsets.symmetric(horizontal: 25), alignment: Alignment.center, decoration: BoxDecoration(color: s == l[i].toLowerCase() || s == l[i] ? c : Colors.white10, borderRadius: BorderRadius.circular(25)), child: Text(l[i]))))));
}
