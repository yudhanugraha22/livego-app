import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';
import 'player.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List activeApis = []; String selS = "melolo"; List ds = []; bool loading = true;
  @override void initState() { super.initState(); _load(); }
  _load() async {
    final p = await SharedPreferences.getInstance();
    List<String> all = ["melolo","dramabox","dotdrama","netshort","flickreels","freereels","rapidtv","goodshort"];
    activeApis = all.where((k) => p.getBool('api_$k') ?? true).toList();
    _fetch();
  }
  _fetch() async {
    setState(() => loading = true);
    final res = await ApiService.get("/api/v2/home?category_p=$selS&lang=id");
    if (res != null && res['success'] == true) setState(() { ds = res['data']; loading = false; });
    else setState(() => loading = false);
  }
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF161B22), title: const Text("Livego", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)), actions: [IconButton(icon: const Icon(Icons.search), onPressed: (){})]),
      body: Column(children: [
        SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: activeApis.length, itemBuilder: (ctx, i)=>Padding(padding: const EdgeInsets.only(right: 8), child: TVButton(onTap: (){ setState(()=>selS=activeApis[i]); _fetch(); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), alignment: Alignment.center, decoration: BoxDecoration(color: selS == activeApis[i] ? const Color(0xFF8B5CF6) : Colors.white10, borderRadius: BorderRadius.circular(20)), child: Text(activeApis[i].toUpperCase())))))),
        Expanded(child: loading ? const Center(child: CircularProgressIndicator()) : GridView.builder(padding: const EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isT?7:4, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: ds.length, itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c)=>DetailPage(id: ds[i]['id'], source: selS))), child: Column(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(ds[i]['cover'], fit: BoxFit.cover))), Text(ds[i]['title'], maxLines:1, style: const TextStyle(fontSize: 10))]))))
      ]),
    );
  }
}
