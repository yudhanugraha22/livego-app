import 'package:flutter/material.dart';

void main() => runApp(const LiveGoApp());

class LiveGoApp extends StatelessWidget {
  const LiveGoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _idx = 2; // Default ke Akun untuk test ini
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _idx,
        children: [
          const Center(child: Text("HOME")),
          const Center(child: Text("UNDUHAN")),
          const AccountScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(color: Color(0xFF090B10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navBtn(Icons.home_filled, "HOME", 0),
            _navBtn(Icons.download_for_offline, "UNDUHAN", 1),
            _navBtn(Icons.person, "AKUN", 2),
          ],
        ),
      ),
    );
  }

  Widget _navBtn(IconData ico, String lab, int i) => InkWell(
    onTap: () => setState(() => _idx = i),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(ico, color: _idx == i ? const Color(0xFF00D9FF) : Colors.grey),
      Text(lab, style: TextStyle(fontSize: 9, color: _idx == i ? const Color(0xFF00D9FF) : Colors.grey)),
    ]),
  );
}

// ==========================================
// HALAMAN AKUN (DARI BUILD SEBELUMNYA)
// ==========================================
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090B10),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 60),
          _header(),
          const SizedBox(height: 30),
          const Text("KOLEKSI CEPAT", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          _card([
            _item(Icons.history, "Riwayat", "Lanjutkan tontonan terakhir", () {}),
            _item(Icons.favorite_border, "Favorit", "Daftar drama disimpan", () {}),
            _item(Icons.settings_outlined, "Pengaturan", "Tampilan, Player, DRM", () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsScreen()));
            }),
          ]),
        ],
      ),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: const Color(0xFF121820)),
    child: Row(children: [
      const CircleAvatar(radius: 30, backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow_rounded, size: 40, color: Colors.white)),
      const SizedBox(width: 15),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("User Penggemar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("LiveGo Premium", style: TextStyle(color: Colors.grey, fontSize: 12))])
    ]),
  );

  Widget _card(List<Widget> i) => Container(margin: const EdgeInsets.only(top: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: const Color(0xFF121820)), child: Column(children: i));
  Widget _item(IconData i, String t, String s, VoidCallback c) => ListTile(onTap: c, leading: Icon(i, color: Colors.white70), title: Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), subtitle: Text(s, style: const TextStyle(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right));
}

// ==========================================
// HALAMAN PENGATURAN (IDENTIK SCREENSHOT)
// ==========================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _navValue = 1;
  bool _bgPoster = true;
  bool _useCache = true;
  bool _manualRot = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090B10),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            _buildPremiumHeader(context),
            _buildSection("TAMPILAN & NAVIGASI", [
              _buildRadio(0, "Otomatis (Ikuti Hardware)"),
              _buildRadio(1, "Smartphone / Tablet (Android)"),
              _buildRadio(2, "Android TV (Leanback Style)"),
            ]),
            _buildSection("PLAYER", [
              _buildSwitch(Icons.image_outlined, "Tampilkan Background Poster", "Tampilkan poster sebagai ambience", _bgPoster, (v) => setState(() => _bgPoster = v)),
              _buildSwitch(Icons.cached, "Gunakan Cache Playback", "Simpan potongan stream sementara", _useCache, (v) => setState(() => _useCache = v)),
              _buildSwitch(Icons.screen_rotation, "Tampilkan Tombol Rotasi Manual", "Tampilkan kontrol rotasi saat menonton", _manualRot, (v) => setState(() => _manualRot = v)),
              _buildActionTile(Icons.lock_outline, "Kompatibilitas Widevine DRM", "Widevine L3 akan dipaksa...", "PAKSA L3"),
            ]),
            _buildSection("SUMBER & IZIN", [
              _buildActionTile(Icons.layers_outlined, "Kelola Sumber Data", "Aktifkan hanya source yang ingin muncul", ""),
            ]),
            _buildSection("PERAWATAN", [
              _buildActionTile(Icons.delete_sweep_outlined, "Hapus Semua Cache", "Bersihkan cache streaming dan gambar", "", isRed: true),
            ]),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext ctx) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(colors: [const Color(0xFF121820), const Color(0xFF090B10).withOpacity(0)]),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(ctx)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF00D9FF).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Text("CONTROL CENTER", style: TextStyle(color: Color(0xFF00D9FF), fontSize: 10, fontWeight: FontWeight.bold))),
      ]),
      const SizedBox(height: 15),
      const Text("Pengaturan LiveGo", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text("Rapikan mode tampilan, player, source, izin, dan cache dari satu tempat yang lebih nyaman dipakai di mobile maupun Android TV.", style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4)),
      const SizedBox(height: 20),
      Row(children: ["Display", "Player", "Source"].map((t) => Container(margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)), child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))).toList()),
    ]),
  );

  Widget _buildSection(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.only(left: 25, bottom: 10, top: 20), child: Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
      Container(margin: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: const Color(0xFF121820)), child: Column(children: children)),
    ],
  );

  Widget _buildRadio(int val, String title) => RadioListTile(
    value: val, groupValue: _navType(), 
    activeColor: const Color(0xFF00D9FF),
    title: Text(title, style: const TextStyle(fontSize: 14)),
    onChanged: (v) => setState(() => _navValue = v as int),
  );

  int _navType() => _navValue;

  Widget _buildSwitch(IconData icon, String title, String sub, bool val, Function(bool) onCh) => SwitchListTile(
    secondary: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: Icon(icon, color: Colors.white70, size: 20)),
    title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    subtitle: Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    value: val, onChanged: onCh, activeColor: const Color(0xFF00D9FF),
  );

  Widget _buildActionTile(IconData icon, String title, String sub, String badge, {bool isRed = false}) => ListTile(
    leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: Icon(icon, color: isRed ? Colors.redAccent : Colors.white70, size: 20)),
    title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isRed ? Colors.redAccent : Colors.white)),
    subtitle: Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      if (badge.isNotEmpty) Text(badge, style: const TextStyle(color: Color(0xFF00D9FF), fontWeight: FontWeight.bold, fontSize: 11)),
      Icon(Icons.arrow_forward_ios, size: 14, color: isRed ? Colors.redAccent : Colors.white24),
    ]),
  );
}
