import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // Variabel Pengaturan (10 Poin)
  String nav = "Otomatis (Ikuti Hardware)";
  String drm = "Auto";
  bool bgPoster = false;
  bool useCache = true;
  bool rotasiManual = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // POIN: Load data permanen saat buka menu
  _loadSettings() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      nav = p.getString('nav') ?? "Otomatis (Ikuti Hardware)";
      drm = p.getString('drm') ?? "Auto";
      bgPoster = p.getBool('bgPoster') ?? false;
      useCache = p.getBool('useCache') ?? true;
      rotasiManual = p.getBool('rotasiManual') ?? true;
    });
  }

  // POIN: Simpan data permanen ke memori HP
  _save(String key, dynamic val) async {
    final p = await SharedPreferences.getInstance();
    if (val is String) p.setString(key, val);
    if (val is bool) p.setBool(key, val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const SizedBox(height: 40),
          // HEADER PROFIL CINEFLOW
          _buildHeader(),
          const SizedBox(height: 25),

          // SEKSI 1: KOLEKSI
          _label("KOLEKSI CEPAT"),
          _card([
            _item(Icons.history, "Riwayat", "Lihat tontonan terakhir", () {}), // Poin 1
            _item(Icons.favorite_border, "Favorit", "Drama yang Anda simpan", () {}), // Poin 2
          ]),

          // SEKSI 2: PENGATURAN (10 POIN)
          _label("PENGATURAN SISTEM"),
          _card([
            _item(Icons.settings_suggest, "Navigasi Hardware", nav, _showNavDialog), // Poin 3
            _switch(Icons.image_outlined, "Tampilkan Background Poster", bgPoster, (v) {
              setState(() => bgPoster = v);
              _save('bgPoster', v);
            }), // Poin 4
            _switch(Icons.cached, "Gunakan Cache Playback", useCache, (v) {
              setState(() => useCache = v);
              _save('useCache', v);
            }), // Poin 5
            _switch(Icons.screen_rotation, "Tombol Rotasi Manual", rotasiManual, (v) {
              setState(() => rotasiManual = v);
              _save('rotasiManual', v);
            }), // Poin 6
            _item(Icons.lock_outline, "Widevine DRM", drm, _showDRMDialog), // Poin 7
            _item(Icons.layers_outlined, "Kelola Sumber Data", "Aktifkan 8 API Dracin", _goSourceManager), // Poin 8
          ]),

          // SEKSI 3: DUKUNGAN
          _label("DUKUNGAN"),
          _card([
            _item(Icons.system_update_alt, "Periksa Pembaruan", "Versi 1.0.0", () {}), // Poin 9
            _item(Icons.message_outlined, "Feedback & Dukungan", "Hubungi Deploper", () {}), // Poin 10
          ]),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // WIDGETS KOMPONEN
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(25)),
      child: Row(children: [
        const CircleAvatar(radius: 35, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white, size: 40)),
        const SizedBox(width: 15),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("User Penggemar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Akun CineFlow", style: TextStyle(color: Colors.grey, fontSize: 13)),
        ]),
      ]),
    );
  }

  void _showNavDialog() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("Tampilan Navigasi"), backgroundColor: const Color(0xFF161B22),
      content: Column(mainAxisSize: MainAxisSize.min, children: ["Otomatis (Ikuti Hardware)", "Smartphone / Tablet", "Android TV (Leanback)"].map((v) => RadioListTile(
        title: Text(v, style: const TextStyle(fontSize: 14)), value: v, groupValue: nav,
        onChanged: (val) { setState(() => nav = val!); _save('nav', val); Navigator.pop(c); },
      )).toList()),
    ));
  }

  void _showDRMDialog() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("Mode Widevine DRM"), backgroundColor: const Color(0xFF161B22),
      content: Column(mainAxisSize: MainAxisSize.min, children: ["Auto", "Paksa L3", "Paksa Berhenti L3"].map((v) => RadioListTile(
        title: Text(v, style: const TextStyle(fontSize: 14)), value: v, groupValue: drm,
        onChanged: (val) { setState(() => drm = val!); _save('drm', val); Navigator.pop(c); },
      )).toList()),
    ));
  }

  void _goSourceManager() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => const SourceManagerPage()));
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)));
  Widget _card(List<Widget> i) => Container(margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Column(children: i));
  Widget _item(IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.white70, size: 20), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.blueAccent)), trailing: const Icon(Icons.chevron_right, size: 18)));
  Widget _switch(IconData i, String t, bool v, Function(bool) c) => TVButton(onTap: () => c(!v), child: SwitchListTile(secondary: Icon(i, color: Colors.white70, size: 20), title: Text(t, style: const TextStyle(fontSize: 14)), value: v, onChanged: c, activeColor: Colors.blueAccent));
}

class SourceManagerPage extends StatelessWidget {
  const SourceManagerPage({super.key});
  @override
  Widget build(BuildContext context) {
    final List<String> apis = ["Melolo", "DramaBox", "DotDrama", "Netshort", "FlickReels", "FreeReels", "RapidTV", "GoodShort"];
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF161B22), title: const Text("Kelola Sumber Data")),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: apis.length,
        itemBuilder: (c, i) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(15)),
          child: TVButton(onTap: () {}, child: SwitchListTile(title: Text(apis[i]), value: true, onChanged: (v) {}, activeColor: Colors.blueAccent)),
        ),
      ),
    );
  }
}
