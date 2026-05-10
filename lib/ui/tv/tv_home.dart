import 'package:flutter/material.dart';
import '../../core/api_engine.dart';
import '../shared/widgets.dart';
import '../player/player_screen.dart';

class TVHome extends StatefulWidget {
  const TVHome({super.key});
  @override State<TVHome> createState() => _TVHomeState();
}
class _TVHomeState extends State<TVHome> {
  List ds = []; bool load = true; String plat = "melolo";
  @override void initState() { super.initState(); _fetch(); }
  _fetch() async {
    setState(()=>load=true);
    final res = await ApiEngine.request("/api/v2/home?category_p=$plat&lang=id");
    setState((){ if(res!=null) ds = res['data']; load = false; });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: Row(children: [
      Container(width: 80, color: const Color(0xFF161B22), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.home, color: Colors.blueAccent, size: 35), SizedBox(height: 40), Icon(Icons.person, color: Colors.grey, size: 35)])),
      Expanded(child: Column(children: [
        SizedBox(height: 60, child: ListView(scrollDirection: Axis.horizontal, children: ["Melolo","FreeReels","FlickReels","RapidTV"].map((p)=>Padding(padding: const EdgeInsets.all(10), child: TVButton(onTap: (){ plat=p.toLowerCase(); _fetch(); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 30), alignment: Alignment.center, decoration: BoxDecoration(color: plat==p.toLowerCase()?Colors.deepPurple:Colors.white10, borderRadius: BorderRadius.circular(10)), child: Text(p))))).toList())),
        Expanded(child: load ? const Center(child: CircularProgressIndicator()) : GridView.builder(padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.65, mainAxisSpacing: 15, crossAxisSpacing: 15), itemCount: ds.length, itemBuilder: (c, i) => TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>LivegoPlayer(id: ds[i]['id'], source: plat, title: ds[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(ds[i]['cover'], fit: BoxFit.cover)))))
      ]))
    ]));
  }
}
