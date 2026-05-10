// lib/core/config/api_config.dart

class ApiConfig {
  static const String baseUrl = "https://api-drama.dobda.id";
  static const String apiKey = "starter"; // Paket starter Anda
  
  // Secret Key untuk generate tanda tangan HMAC-SHA256 agar request tidak diblokir
  static const String apiSecret = "22dfb2b849814054af0491ff2ee3ffe33989313d7d38e97aae659757a4cf8960";
}
