import 'package:flutter/material.dart';
import 'widgets.dart';
import 'api_service.dart';
import 'player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List ds = []; bool load = true; String err = ""; 
  String plat = "melolo";

  @override void initState() { super.initState(); _fetch(); }

  _fetch() async {
    setState(() { load = true; err = ""; });
    try {
      final res = await ApiService.get("/api/v2/home?category_p=$plat&lang=id");
      if (res != null && res['success'] == true) {
        setState(() { ds = res['data']; load = false; });
      } else {
        setState(() { err = "API Menolak: ${res != null ? res['message'] : 'Tidak ada respon'}"; load = false; });
      }
    } catch (e) {
      setState(() { err = "Koneksi Error: $e"; load = false; });
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(title: const Text("Livego Debug Mode")),
      body: Column(children: [
        TVButton(onTap: _fetch, child: Container(padding: EdgeInsets.all(10), color: Colors.blue, child: Text("Klik Untuk Segarkan"))),
        if (load) const Center(child: CircularProgressIndicator()),
        if (err.isNotEmpty) Padding(padding: EdgeInsets.all(20), child: Text(err, style: TextStyle(color: Colors.red))),
        if (!load && ds.isNotEmpty) Expanded(child: ListView.builder(itemCount: ds.length, itemBuilder: (c,i)=>ListTile(title: Text(ds[i]['title']))))
      ]),
    );
  }
}
