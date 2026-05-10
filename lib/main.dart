// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Deteksi jenis perangkat (HP atau TV)
  final deviceInfo = DeviceInfoPlugin();
  bool isTv = false;

  try {
    if (RegExp(r'TV|Box|Player|Cast|Fire', caseSensitive: false).hasMatch(Uri.base.toString())) {
      isTv = true;
    } else {
      final androidInfo = await deviceInfo.androidInfo;
      final systemFeatures = androidInfo.systemFeatures;
      if (systemFeatures.contains('android.software.leanback') || 
          androidInfo.hardware.toLowerCase().contains('tv') ||
          androidInfo.model.toLowerCase().contains('tv')) {
        isTv = true;
      }
    }
  } catch (e) {
    // Default fallback jika gagal deteksi
    isTv = false;
  }

  // Jika TV, kunci orientasi layar ke Landscape
  if (isTv) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else {
    // Jika HP, kunci ke Portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  runApp(
    ProviderScope(
      child: LiveGoApp(isTv: isTv),
    ),
  );
}

class LiveGoApp extends StatelessWidget {
  final bool isTv;
  const LiveGoApp({super.key, required this.isTv});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiveGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0C1B), // Background ungu gelap premium
        primaryColor: const Color(0xFF00D9FF), // Cyan neon
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_fill,
                size: 80,
                color: Color(0xFF00D9FF),
              ),
              const SizedBox(height: 16),
              Text(
                isTv ? 'LiveGo Android TV Edition' : 'LiveGo Mobile Edition',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mempersiapkan Bioskop Premium Anda...',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
