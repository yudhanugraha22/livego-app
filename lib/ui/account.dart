import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';
import 'home.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String navType = "Otomatis", drmMode = "Auto";
  bool bgPoster = true, useCache = true;

  @override void initState() { super.initState(); _load(); }
  _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      navType = p.getString('navType') ?? "Otomatis";
      drmMode = p.getString('drmMode') ?? "Auto";
    });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        const SizedBox(height: 50),
        _header(),
        const SizedBox(height: 25),
        _label("KOLEKSI CEPAT"),
        _card([
          _item(Icons.history, "Riwayat", "Lihat tontonan", () {}),
          _item(Icons.favorite, "Favorit", "Drama simpan", () {}),
        ]),
        _label("PENGATURAN SYSTEM"),
        _card([
          _item(Icons.settings_suggest, "Navigasi Hardware", navType, () {}),
          _switch(Icons.cached, "Gunakan Cache Playback", useCache, (v) => setState(() => useCache = v)),
          _item(Icons.lock_outline, "Widevine DRM", drmMode, () {}),
          _item(Icons.layers_outlined, "Kelola Sumber Data", "Atur 24 API", () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const SourceManagerPage()));
          }),
        ]),
        const SizedBox(height: 50),
      ]),
    );
  }

  Widget _header() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Row(children: [const CircleAvatar(radius: 30, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.person, color: Colors.white)), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("User Penggemar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("Plan: STARTER", style: TextStyle(color: Colors.blueAccent, fontSize: 12))])]));
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)));
  Widget _card(List<Widget> i) => Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.only(bottom: 20), child: Column(children: i));
  Widget _item(IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right, size: 16)));
  Widget _switch(IconData i, String t, bool v, Function(bool) c) => TVButton(onTap: () => c(!v), child: SwitchListTile(secondary: Icon(i, color: Colors.white70), title: Text(t, style: const TextStyle(fontSize: 14)), value: v, onChanged: c, activeColor: Colors.blueAccent));
}

class SourceManagerPage extends StatefulWidget {
  const SourceManagerPage({super.key});
  @override State<SourceManagerPage> createState() => _SourceManagerState();
}

class _SourceManagerState extends State<SourceManagerPage> {
  // DAFTAR 24 PLATFORM LENGKAP SESUAI GAMBAR
  final List<String> allPlatforms = [
    "Melolo", "DramaBox", "Netshort", "Goodshort", "Shortmax", "DramaWave", 
    "FlickReels", "FreeReels", "ReelShort", "Meloshort", "FlexTV", "DramaRush", 
    "RapidTV", "StardustTV", "Dramanova", "Fundrama", "Starshort", "Dramapops", 
    "Snackshort", "Reelife", "Dramabite", "Sodareels", "Bilitv", "iDrama"
  ];
  
  Map<String, bool> status = {};

  @override void initState() { super.initState(); _loadStatus(); }

  _loadStatus() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      for (var api in allPlatforms) {
        // Default ON hanya untuk 4 platform Anda
        bool isDefaultOn = ["Melolo", "FreeReels", "FlickReels", "RapidTV"].contains(api);
        status[api] = p.getBool('api_$api') ?? isDefaultOn;
      }
    });
  }

  _toggle(String name, bool val) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('api_$name', val);
    setState(() { status[name] = val; });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(title: const Text("Kelola Sumber Data"), backgroundColor: const Color(0xFF161B22)),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: allPlatforms.length,
        itemBuilder: (c, i) {
          String name = allPlatforms[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(15)),
            child: TVButton(
              onTap: () => _toggle(name, !(status[name] ?? false)),
              child: SwitchListTile(
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text((status[name] ?? false) ? "Status: AKTIF" : "Status: NONAKTIF", style: TextStyle(color: (status[name] ?? false) ? Colors.green : Colors.grey, fontSize: 11)),
                value: status[name] ?? false,
                onChanged: (v) => _toggle(name, v),
                activeColor: Colors.blueAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}
