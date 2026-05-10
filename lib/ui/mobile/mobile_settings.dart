import 'package:flutter/material.dart';
import '../../core/services/cache_service.dart';

class MobileSettings extends StatefulWidget {
  const MobileSettings({super.key});

  @override
  State<MobileSettings> createState() => _MobileSettingsState();
}

class _MobileSettingsState extends State<MobileSettings> {
  String _cacheSize = "Menghitung...";

  @override
  void initState() {
    super.initState();
    _calculateCache();
  }

  Future<void> _calculateCache() async {
    final history = await CacheService.getAllHistory();
    setState(() {
      _cacheSize = "${history.length} Item Riwayat";
    });
  }

  Future<void> _clearAllCache() async {
    // Tampilkan dialog konfirmasi
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B30),
        title: const Text('Hapus Riwayat', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus semua riwayat tontonan?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              await CacheService.clearAllHistory();
              Navigator.pop(context);
              _calculateCache();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua riwayat tontonan berhasil dihapus!'),
                  backgroundColor: Color(0xFF00D9FF),
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PENGATURAN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color(0xFF00D9FF),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Aplikasi & Penyimpanan
          const Text(
            'Penyimpanan & Data',
            style: TextStyle(color: Color(0xFF00D9FF), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF1E1B30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storage, color: Colors.white70),
                  title: const Text('Cache Riwayat', style: TextStyle(color: Colors.white)),
                  subtitle: Text(_cacheSize, style: const TextStyle(color: Colors.white38)),
                  trailing: TextButton(
                    onPressed: _clearAllCache,
                    child: const Text('BERSIHKAN', style: TextStyle(color: Color(0xFF00D9FF))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Info Sistem
          const Text(
            'Informasi Sistem',
            style: TextStyle(color: Color(0xFFFF007F), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF1E1B30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.phone_android, color: Colors.white70),
                  title: Text('Mode Perangkat', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Mobile / Tablet', style: TextStyle(color: Colors.white38)),
                ),
                Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.white70),
                  title: Text('Versi Aplikasi', style: TextStyle(color: Colors.white)),
                  subtitle: Text('v1.0.0-Premium', style: TextStyle(color: Colors.white38)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
