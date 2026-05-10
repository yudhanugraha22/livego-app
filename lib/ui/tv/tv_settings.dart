import 'package:flutter/material.dart';
import '../../core/services/cache_service.dart';

class TvSettings extends StatefulWidget {
  const TvSettings({super.key});

  @override
  State<TvSettings> createState() => _TvSettingsState();
}

class _TvSettingsState extends State<TvSettings> {
  String _cacheSize = "Menghitung...";
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _calculateCache();
  }

  Future<void> _calculateCache() async {
    final history = await CacheService.getAllHistory();
    setState(() {
      _cacheSize = "${history.length} Item Riwayat Tontonan";
    });
  }

  Future<void> _clearAllCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B30),
        title: const Text('Hapus Semua Riwayat?', style: TextStyle(color: Colors.white)),
        content: const Text('Pilihan ini akan menghapus seluruh data pemutaran Anda.', style: TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white12),
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await CacheService.clearAllHistory();
              Navigator.pop(context);
              _calculateCache();
            },
            child: const Text('Hapus Permanen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090615),
      body: Row(
        children: [
          // Sidebar Navigasi Kiri (TV)
          Container(
            width: 80,
            color: const Color(0xFF0D0A1E),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white38, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 32),
                IconButton(
                  icon: const Icon(Icons.settings, color: Color(0xFF00D9FF), size: 30),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Konten Utama Kanan
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengaturan Sistem TV',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Menu 1: Bersihkan Cache (Remote Friendly)
                  InkWell(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) setState(() => _focusedIndex = 0);
                    },
                    onTap: _clearAllCache,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _focusedIndex == 0 ? const Color(0xFF00D9FF) : const Color(0xFF1E1B30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _focusedIndex == 0 ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.delete_sweep,
                                color: _focusedIndex == 0 ? Colors.black : const Color(0xFF00D9FF),
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bersihkan Riwayat Tontonan',
                                    style: TextStyle(
                                      color: _focusedIndex == 0 ? Colors.black : Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _cacheSize,
                                    style: TextStyle(
                                      color: _focusedIndex == 0 ? Colors.black54 : Colors.white38,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            'TEKAN OK',
                            style: TextStyle(
                              color: _focusedIndex == 0 ? Colors.black : Colors.white38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Menu 2: Info Sistem TV (Hanya Informasi)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.tv, color: Color(0xFFFF007F), size: 32),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mode Perangkat Terdeteksi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Android TV / Smart TV / STB Box',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
