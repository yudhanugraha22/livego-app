// lib/main.dart

import 'package:flutter/material.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/device_utils.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  // Pastikan binding Flutter sudah siap sebelum melakukan inisialisasi service
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Deteksi Perangkat (HP vs TV)
  await DeviceUtils.init();

  // 2. Inisialisasi Penyimpanan Setelan Lokal (SharedPreferences)
  await StorageService.init();

  runApp(const LiveGoApp());
}

class LiveGoApp extends StatelessWidget {
  const LiveGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiveGo CineFlow',
      debugShowCheckedModeBanner: false,
      
      // Menggunakan tema gelap neon premium kustom kita
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Rute awal aplikasi (otomatis mengarah ke TvHome atau MobileHome)
      initialRoute: AppRoutes.initial,
      routes: AppPages.routes,
    );
  }
}
