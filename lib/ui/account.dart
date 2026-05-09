import 'package:flutter/material.dart';
import 'widgets.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("Akun Saya"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, size: 60),
                ),
                const SizedBox(height: 12),
                const Text("User Penggemar", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text("Livego Premium", 
                    style: TextStyle(color: Colors.greenAccent)),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Pengaturan System
          const Text("PENGATURAN SYSTEM", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          
          _buildSettingTile(Icons.settings, "Navigasi Hardware", "Otomatis"),
          _buildToggleTile("Gunakan Cache Playback", true),
          _buildSettingTile(Icons.lock, "Widevine DRM", "Auto"),
          _buildSettingTile(Icons.data_usage, "Kelola Sumber Data", "24 API"),

          const SizedBox(height: 30),
          
          // Koleksi
          const Text("KOLEKSI", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          
          _buildCollectionTile(Icons.history, "Riwayat", "Lihat"),
          _buildCollectionTile(Icons.favorite, "Favorit", "Drama"),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle) {
    return Card(
      color: const Color(0xFF161B22),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {}, // tambahkan fungsi nanti
      ),
    );
  }

  Widget _buildToggleTile(String title, bool value) {
    return Card(
      color: const Color(0xFF161B22),
      child: ListTile(
        title: Text(title),
        trailing: Switch(value: value, onChanged: (v){}),
      ),
    );
  }

  Widget _buildCollectionTile(IconData icon, String title, String subtitle) {
    return Card(
      color: const Color(0xFF161B22),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
