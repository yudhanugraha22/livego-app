import 'package:flutter/material.dart';

void main() => runApp(const LiveGoApp());

class LiveGoApp extends StatelessWidget {
  const LiveGoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const AccountScreen(),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090B10), // Hitam pekat CineFlow
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            // HEADER PROFIL
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: const Color(0xFF121820),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // LOGO BULAT GLOW
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                          boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.3), blurRadius: 15)],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, size: 45, color: Color(0xFF8B5CF6)),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("User Penggemar", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("Akun LiveGo\nMasuk cepat ke riwayat, favorit, pengaturan, dan update tanpa harus bolak-balik layar.", 
                            style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.3)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _socialBtn("Telegram"),
                      const SizedBox(width: 10),
                      _socialBtn("WhatsApp"),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text("KOLEKSI CEPAT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            
            // CARD KOLEKSI
            _menuGroup([
              _menuItem(Icons.history, "Riwayat", "Lanjutkan dari tontonan terakhir yang sudah sempat dibuka."),
              _menuItem(Icons.favorite_border, "Favorit", "Buka daftar judul yang Anda simpan sebagai favorit."),
              _menuItem(Icons.settings_outlined, "Pengaturan", "Atur tampilan, player, subtitle, dan source aktif."),
            ]),

            const SizedBox(height: 30),
            const Text("APLIKASI & DUKUNGAN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 12),

            // CARD DUKUNGAN
            _menuGroup([
              _menuItem(Icons.file_download_outlined, "Periksa Pembaruan", "Cek versi terbaru LiveGo dan pasang update jika tersedia."),
              _menuItem(Icons.share_outlined, "Dukung LiveGo", "Bantu maintenance dan eksperimen fitur baru lewat donasi."),
              _menuItem(Icons.send_outlined, "Kirim Feedback", "Laporkan bug, masalah sumber/server, atau usulkan fitur."),
              _menuItem(Icons.help_outline, "Bantuan", "Panduan bantuan singkat untuk fitur utama LiveGo."),
            ]),
            const SizedBox(height: 100),
          ],
        ),
      ),
      // FLOATING BOTTOM NAV
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _socialBtn(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: const Color(0xFF1C222D),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
  );

  Widget _menuGroup(List<Widget> items) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: const Color(0xFF121820),
    ),
    child: Column(children: items),
  );

  Widget _menuItem(IconData icon, String title, String sub) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    leading: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white70, size: 22),
    ),
    title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ),
    trailing: const Icon(Icons.arrow_forward, color: Colors.white24, size: 18),
  );

  Widget _buildBottomNav() => Container(
    margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
    height: 70,
    decoration: BoxDecoration(
      color: const Color(0xFF121820),
      borderRadius: BorderRadius.circular(25),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _navItem(Icons.home_filled, "HOME", false),
        _navItem(Icons.download_for_offline, "UNDUHAN", false),
        _navItem(Icons.person, "AKUN", true),
      ],
    ),
  );

  Widget _navItem(IconData icon, String label, bool active) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: active ? const Color(0xFF00D9FF) : Colors.grey, size: 26),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 9, color: active ? const Color(0xFF00D9FF) : Colors.grey, fontWeight: FontWeight.bold)),
    ],
  );
}
