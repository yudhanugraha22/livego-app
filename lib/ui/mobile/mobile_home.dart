import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../shared/widgets.dart';
import '../player/player_screen.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});
  @override State<MobileHome> createState() => _MobileHomeState();
}
class _MobileHomeState extends State<MobileHome> {
  List ds = []; Map? banner; bool load = true;
  String plat = "melolo"; String cat = "Dubbing";

  @override void initState() { super.initState(); _fetch(); }
  _fetch() async {
    setState(()=>load=true);
    final bRes = await LiveApi.fetch("/api/v2/banner?category_p=$plat&lang=id");
    if (bRes != null && bRes['data'].isNotEmpty) banner = bRes['data'][0];
    String p = (cat=="Dubbing") ? "/api/v2/search?category_p=$plat&q=sulih suara&lang=id" : "/api/v2/home?category_p=$plat&lang=id";
    final res = await LiveApi.fetch(p);
    setState((){ if(res!=null) ds = res['data']; load = false; });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0D1117), 
      appBar: AppBar(backgroundColor: const Color(0xFF161B22), elevation: 0, title: const Text("Livego", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(child: Column(children: [
        if (banner != null) Container(height: 180, margin: const EdgeInsets.all(15), child: InkWell(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (c)=>LivegoPlayer(id: banner!['id'], source: plat, title: banner!['title']))), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(banner!['cover'], fit: BoxFit.cover, width: double.infinity)), Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black, Colors.transparent])), padding: const EdgeInsets.all(15), alignment: Alignment.bottomLeft, child: Text(banner!['title'], style: const TextStyle(fontWeight: FontWeight.bold)))]))),
        _hList(["Melolo","FreeReels","FlickReels","RapidTV"], plat, (v){ setState(()=>plat=v.toLowerCase()); _fetch(); }, const Color(0xFF8B5CF6)),
        const SizedBox(height: 8),
        _hList(["Dubbing","Populer","New","Trending"], cat, (v){ setState(()=>cat=v); _fetch(); }, Colors.blueAccent),
        load ? const Center(child: CircularProgressIndicator()) : GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: ds.length, itemBuilder: (c, i) => InkWell(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (c)=>LivegoPlayer(id: ds[i]['id'], source: plat, title: ds[i]['title']))), child: Column(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(ds[i]['cover'], fit: BoxFit.cover))), Text(ds[i]['title'], maxLines:1, style: const TextStyle(fontSize: 9))]))),
      ])),
    );
  }
  Widget _hList(List l, String s, Function(String) o, Color c) => SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: l.length, itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.only(right: 8), child: ActionChip(label: Text(l[i]), backgroundColor: s.toLowerCase() == l[i].toLowerCase() || s == l[i] ? c : Colors.white10, onPressed: ()=>o(l[i])))));
}
