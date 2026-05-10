import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../shared/widgets.dart';
import '../player.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});
  @override State<MobileHomePage> createState() => _MobileHomePageState();
}
class _MobileHomePageState extends State<MobileHomePage> {
  List ds = []; bool load = true; String plat = "melolo";
  @override void initState() { super.initState(); _fetch(); }
  _fetch() async {
    setState(()=>load=true);
    final res = await LiveApi.fetch("/api/v2/home?category_p=$plat&lang=id");
    setState((){ if (res != null) ds = res['data']; load = false; });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0D1117), appBar: AppBar(title: const Text("Livego"), backgroundColor: Colors.transparent), body: Column(children: [
      SizedBox(height: 50, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(5), children: ["Melolo","FreeReels","FlickReels","RapidTV"].map((p)=>Padding(padding: const EdgeInsets.only(right: 8), child: ActionChip(label: Text(p), onPressed: (){ plat=p.toLowerCase(); _fetch(); }))).toList())),
      Expanded(child: load ? const Center(child: CircularProgressIndicator()) : GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.65, mainAxisSpacing: 10, crossAxisSpacing: 10), itemCount: ds.length, itemBuilder: (c, i) => InkWell(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>PlayerPage(id: ds[i]['id'], source: plat, title: ds[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(ds[i]['cover'], fit: BoxFit.cover)))))
    ]));
  }
}
