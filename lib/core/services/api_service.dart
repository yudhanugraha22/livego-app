// lib/core/services/api_service.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final String apiSecret = ApiConfig.apiSecret;
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String method = options.method.toUpperCase();
        
        // Membaca path dan query params untuk membentuk payload tanda tangan
        final String pathWithQuery = options.uri.path + 
            (options.uri.query.isNotEmpty ? "?${options.uri.query}" : "");
        
        // Format payload: METHOD:PATH:TIMESTAMP
        final String payload = "$method:$pathWithQuery:$timestamp";
        
        // Melakukan enkripsi HMAC-SHA256
        final List<int> key = utf8.encode(apiSecret);
        final List<int> bytes = utf8.encode(payload);
        final Hmac hmacSha256 = Hmac(sha256, key);
        final Digest signature = hmacSha256.convert(bytes);

        // Menambahkan header yang diwajibkan oleh API server
        options.headers['X-Timestamp'] = timestamp;
        options.headers['X-Signature'] = signature.toString();
        options.headers['X-Api-Key'] = ApiConfig.apiKey;
        options.headers['Accept'] = 'application/json';

        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Deteksi jika limit harian (4000 req) habis atau server sibuk
        if (e.response?.statusCode == 429) {
          print("⚠️ Batas limit request harian API Anda telah habis!");
        }
        return handler.next(e);
      },
    ));
  }

  Dio get client => _dio;
}
