// lib/core/utils/device_utils.dart

import 'package:flutter/services.dart';

class DeviceUtils {
  static bool _isTV = false;

  // Getter global untuk mengecek tipe perangkat di seluruh widget UI
  static bool get isTV => _isTV;

  static Future<void> init() async {
    try {
      // Channel khusus untuk memanggil fungsi bawaan sistem Android
      const platform = MethodChannel('com.livego.app/device_info');
      final String uiMode = await platform.invokeMethod('getUiMode');
      _isTV = (uiMode == 'television');
    } catch (e) {
      // Jika terjadi error (misalnya dijalankan di emulator non-TV atau iOS), default ke HP
      _isTV = false;
    }
  }

  // Fungsi tambahan untuk simulasi/testing mode TV di HP saat proses koding
  static void setDeviceType(bool isTvDevice) {
    _isTV = isTvDevice;
  }
}
