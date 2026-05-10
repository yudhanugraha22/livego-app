// lib/ui/tv/tv_home.dart

import 'package:flutter/material.dart';

class TvHome extends StatelessWidget {
  const TvHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigasi Menu Samping Khas Android TV
          Container(
            width: 80,
            color: const Color(0xFF0F121D),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, color: Color(0xFF00D9FF), size: 30),
                SizedBox(height: 40),
                Icon(Icons.search, color: Colors.grey, size: 30),
                SizedBox(height: 40),
                Icon(Icons.settings, color: Colors.grey, size: 30),
              ],
            ),
          ),
          // Konten Utama TV
          const Expanded(
            child: Center(
              child: Text(
                'LiveGo Android TV Home\n(Ramah Remote D-Pad)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
