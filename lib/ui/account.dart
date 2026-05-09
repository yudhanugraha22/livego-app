import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // Variabel State Pengaturan
  String navType = "Otomatis (Ikuti Hardware)";
  String drmMode = "Auto";
  bool bgPoster = true;
  bool useCache = true;
  bool rotasiManual = true;

  @override
  void initState() { super.initState(); _loadSettings(); }

  // LOAD PENGATURAN DARI MEMORI
  _loadSettings() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      navType = p.getString('navType') ?? "Otomatis (Ikuti Hardware)";
      drmMode = p.getString('drmMode') ?? "Auto";
      bgPoster = p.getBool('bgPoster') ?? true;
      useCache = p.getBool('useCache') ?? true;
      rotasiManual = p.getBool('rotasiManual') ?? true;
    });
  }

  // SIMPAN PENGATURAN
  _save(String k, dynamic v) async {
    final p = await SharedPreferences.getInstance();
    if (v is String) p.setString(k, v); else p.setBool(k, v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const SizedBox(height: 50),
          _buildHeader(),
          const SizedBox(height: 25),
          _label("KOLEKSI CEPAT"),
          _card([
            _item(Icons.history, "Riwayat", "Lihat tontonan terakhir", () => _goPage("Riwayat")),
            _item(Icons.favorite_border, "Favorit", "Drama yang disimpan", () => _goPage("Favorit")),
          ]),
          _label("PENGATURAN SYSTEM"),
          _card([
            _item(Icons.settings_suggest, "Navigasi Hardware", navType, _showNavDialog),
            _switch(Icons.image_outlined, "Background Poster", bgPoster, (v) {
              setState(() => bgPoster = v); _save('bgPoster', v);
            }),
            _switch(Icons.cached, "Gunakan Cache Playback", useCache, (v) {
              setState(() => useCache = v); _save('useCache', v);
            }),
            _switch(Icons.screen_rotation, "Tombol Rotasi Manual", rotasiManual, (v) {
              setState(() => rotasiManual = v); _save('rotasiManual', v);
            }),
            _item(Icons.lock_outline, "Widevine DRM", drmMode, _showDRMDialog),
            _item(Icons.layers_outlined, "Kelola Sumber Data", "Aktifkan 8 API", _goSourceManager),
          ]),
          _label("DUKUNGAN"),
          _card([
            _item(Icons.system_update_alt, "Cek Pembaruan", "v1.0.0", () => _msg("Aplikasi versi terbaru")),
          ]),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // MODAL DIALOGS
  void _showNavDialog() {
    _showListDialog("Tampilan Navigasi", ["Otomatis (Ikuti Hardware)", "Smartphone / Tablet", "Android TV"], navType, (v) {
      setState(() => navType = v); _save('navType', v);
    });
  }

  void _showDRMDialog() {
    _showListDialog("Mode Widevine DRM", ["Auto", "Paksa L3", "Berhenti L3"], drmMode, (v) {
      setState(() => drmMode = v); _save('drmMode', v);
    });
  }

  void _showListDialog(String title, List<String> opts, String current, Function(String) onSel) {
    showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      content: Column(mainAxisSize: MainAxisSize.min, children: opts.map((o) => RadioListTile(
        title: Text(o, style: const TextStyle(color: Colors.white, fontSize: 14)),
        value: o, groupValue: current, activeColor: Colors.blueAccent,
        onChanged: (val) { onSel(val!); Navigator.pop(c); },
      )).toList()),
    ));
  }

  // NAVIGATORS
  void _goPage(String t) => Navigator.push(context, MaterialPageRoute(builder: (c) => Scaffold(appBar: AppBar(title: Text(t)), body: const Center(child: Text("Data Kosong")))));
  void _goSourceManager() => Navigator.push(context, MaterialPageRoute(builder: (c) => const SourceManagerPage()));
  void _msg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // UI COMPONENTS
  Widget _buildHeader() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: Row(children: [const CircleAvatar(radius: 30, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.person, color: Colors.white, size: 35)), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("User Penggemar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("Akun Livego Premium", style: TextStyle(color: Colors.grey, fontSize: 12))])]));
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)));
  Widget _card(List<Widget> i) => Container(decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), margin: const EdgeInsets.only(bottom: 20), child: Column(children: i));
  Widget _item(IconData i, String t, String s, VoidCallback c) => TVButton(onTap: c, child: ListTile(leading: Icon(i, color: Colors.blueAccent), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right, size: 16)));
  Widget _switch(IconData i, String t, bool v, Function(bool) c) => TVButton(onTap: () => c(!v), child: SwitchListTile(secondary: Icon(i, color: Colors.white70), title: Text(t, style: const TextStyle(fontSize: 14)), value: v, onChanged: c, activeColor: Colors.blueAccent));
}

// HALAMAN KELOLA API
class SourceManagerPage extends StatelessWidget {
  const SourceManagerPage({super.key});
  @override
  Widget build(BuildContext context) {
    final List<String> apis = ["Melolo", "DramaBox", "DotDrama", "Netshort", "FlickReels", "FreeReels", "RapidTV", "GoodShort"];
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(title: const Text("Kelola Sumber Data"), backgroundColor: const Color(0xFF161B22)),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: apis.length,
        itemBuilder: (c, i) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(15)),
          child: SwitchListTile(title: Text(apis[i]), value: true, onChanged: (v){}, activeColor: Colors.blueAccent),
        ),
      ),
    );
  }
}
