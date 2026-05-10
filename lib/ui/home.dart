import 'package:flutter/material.dart';
import '../core/api.dart';
import 'widgets.dart';
import 'player.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List ds = []; bool load = true; String plat = "melolo";
  @override void initState() { super.initState(); _fetch(); }
  _fetch() async {
    setState(()=>load=true);
    final res = await LiveApi.fetch("/api/v2/home?category_p=$plat&lang=id");
    if (res != null) setState((){ ds = res['data']; load = false; });
  }
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(backgroundColor: const Color(0xFF0D1117), appBar: AppBar(backgroundColor: const Color(0xFF161B22), title: const Text("Livego")), body: Column(children: [
      SizedBox(height: 50, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8), children: ["Melolo","FreeReels","FlickReels","RapidTV"].map((p)=>Padding(padding: const EdgeInsets.only(right: 10), child: TVButton(onTap: (){ plat=p.toLowerCase(); _fetch(); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: plat==p.toLowerCase()?Colors.blueAccent:Colors.white10, borderRadius: BorderRadius.circular(20)), alignment: Alignment.center, child: Text(p))))).toList())),
      Expanded(child: load ? const Center(child: CircularProgressIndicator()) : GridView.builder(padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isT?7:4, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: ds.length, itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (x)=>PlayerPage(id: ds[i]['id'], source: plat, title: ds[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(ds[i]['cover'], fit: BoxFit.cover)))))
    ]));
  }
}
