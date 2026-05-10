// lib/core/services/storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // Inisialisasi SharedPreferences saat aplikasi pertama kali dibuka
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 1. KELOLA SUMBER DATA (PLATFORM TOGGLE)
  // Menyimpan peta platform aktif ke lokal (Contoh: {"dramawave": true, "melolo": false})
  static Future<void> savePlatformSettings(Map<String, bool> settings) async {
    final String jsonString = jsonEncode(settings);
    await _prefs?.setString('active_platforms', jsonString);
  }

  // Mengambil peta platform aktif (Default: 7 platform utama bernilai true)
  static Map<String, bool> getPlatformSettings() {
    final String? jsonString = _prefs?.getString('active_platforms');
    if (jsonString == null) {
      // Platform uji coba awal yang disepakati aktif secara default
      return {
        'dramawave': true,
        'dramabox': true,
        'freereels': true,
        'moviebox': true,
        'anichin': true,
        'melolo': true,
        'reelshort': true,
      };
    }
    return Map<String, bool>.from(jsonDecode(jsonString));
  }

  // 2. SETTING USER LAINNYA
  static Future<void> saveSubtitleLanguage(String lang) async {
    await _prefs?.setString('pref_subtitle_lang', lang);
  }

  static String getSubtitleLanguage() {
    return _prefs?.getString('pref_subtitle_lang') ?? 'id'; // Default Indonesia
  }

  static Future<void> saveAudioTrack(String track) async {
    await _prefs?.setString('pref_audio_track', track);
  }

  static String getAudioTrack() {
    return _prefs?.getString('pref_audio_track') ?? 'original'; // Default Original
  }

  static Future<void> saveAutoPlayNext(bool value) async {
    await _prefs?.setBool('pref_auto_play', value);
  }

  static bool getAutoPlayNext() {
    return _prefs?.getBool('pref_auto_play') ?? true; // Default ON
  }
}
