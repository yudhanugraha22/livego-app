import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://api-drama.dobda.id";
  // Secret Key Starter Anda
  static const String secret = "22dfb2b849814054af0491ff2ee3ffe33989313d7d38e97aae659757a4cf8960";

  static Future<dynamic> get(String path) async {
    String ts = DateTime.now().millisecondsSinceEpoch.toString();
    // Payload sesuai dokumentasi: METHOD:PATH:TIMESTAMP
    String payload = "GET:$path:$ts";
    
    var key = utf8.encode(secret);
    var bytes = utf8.encode(payload);
    var hmac = Hmac(sha256, key);
    var sig = hmac.convert(bytes);

    try {
      final response = await http.get(
        Uri.parse(baseUrl + path),
        headers: {
          "X-Timestamp": ts,
          "X-Signature": sig.toString(),
          "Accept": "application/json",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) { return null; }
    return null;
  }
}
