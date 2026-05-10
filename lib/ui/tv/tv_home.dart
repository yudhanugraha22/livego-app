import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../shared/widgets.dart';
import '../player.dart';

class TVHomePage extends StatefulWidget {
  const TVHomePage({super.key});
  @override State<TVHomePage> createState() => _TVHomePageState();
}
class _TVHomePageState extends State<TVHomePage> {
  List ds = []; bool load = true; String plat = "melolo";
  @override void initState() { super.initState(); _fetch(); }
  _fetch() async {
    setState(()=>load=true);
    final res = await LiveApi.fetch("/api/v2/home?category_p=$plat&lang=id");
    setState((){ if (res != null) ds = res['data']; load = false; });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: Column(children: [
      SizedBox(height: 60, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(10), children: ["Melolo","FreeReels","FlickReels","RapidTV"].map((p)=>Padding(padding: const EdgeInsets.only(right: 15), child: TVButton(onTap: (){ plat=p.toLowerCase(); _fetch(); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 30), alignment: Alignment.center, decoration: BoxDecoration(color: plat==p.toLowerCase()?Colors.deepPurple:Colors.white10, borderRadius: BorderRadius.circular(10)), child: Text(p, style: const TextStyle(fontWeight: FontWeight.bold)))))).toList())),
      Expanded(child: load ? const Center(child: CircularProgressIndicator()) : GridView.builder(padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.65, mainAxisSpacing: 15, crossAxisSpacing: 15), itemCount: ds.length, itemBuilder: (c, i) => TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>PlayerPage(id: ds[i]['id'], source: plat, title: ds[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(ds[i]['cover'], fit: BoxFit.cover)))))
    ]));
  }
}
