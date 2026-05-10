import 'package:flutter/material.dart';
import '../../core/api_engine.dart';
import '../player/player_screen.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});
  @override State<MobileHome> createState() => _MobileHomeState();
}
class _MobileHomeState extends State<MobileHome> {
  List ds = []; bool load = true; String plat = "melolo";
  @override void initState() { super.initState(); _fetch(); }
  _fetch() async {
    setState(()=>load=true);
    final res = await ApiEngine.request("/api/v2/home?category_p=$plat&lang=id");
    setState((){ if(res!=null) ds = res['data']; load = false; });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0D1117), appBar: AppBar(title: const Text("Livego Mobile"), backgroundColor: Colors.transparent), body: Column(children: [
      SizedBox(height: 50, child: ListView(scrollDirection: Axis.horizontal, children: ["Melolo","FreeReels","FlickReels","RapidTV"].map((p)=>Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: ActionChip(label: Text(p), onPressed: (){ plat=p.toLowerCase(); _fetch(); }))).toList())),
      Expanded(child: load ? const Center(child: CircularProgressIndicator()) : GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.65, mainAxisSpacing: 10, crossAxisSpacing: 10), itemCount: ds.length, itemBuilder: (c, i) => InkWell(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>LivegoPlayer(id: ds[i]['id'], source: plat, title: ds[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(ds[i]['cover'], fit: BoxFit.cover)))))
    ]));
  }
}
