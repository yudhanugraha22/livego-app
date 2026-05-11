import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class ApiEngine {
  static const String secret = "22dfb2b849814054af0491ff2ee3ffe33989313d7d38e97aae659757a4cf8960";
  static const String baseUrl = "https://api-drama.dobda.id";

  static Future<dynamic> request(String path) async {
    // API Drama butuh waktu ms milidetik yang presisi
    String ts = DateTime.now().millisecondsSinceEpoch.toString();
    String payload = "GET:$path:$ts";
    var key = utf8.encode(secret);
    var bytes = utf8.encode(payload);
    var hmacSha256 = Hmac(sha256, key);
    var sig = hmacSha256.convert(bytes);

    try {
      final r = await http.get(Uri.parse("$baseUrl$path"), 
      headers: {
        "X-Timestamp": ts, 
        "X-Signature": sig.toString(),
        "Accept": "application/json"
      }).timeout(const Duration(seconds: 15));
      
      if (r.statusCode == 200) {
        return json.decode(r.body);
      } else {
        return {"error": "Server Error: ${r.statusCode}"};
      }
    } catch (e) { 
      return {"error": "Connection Problem: $e"}; 
    }
  }
}
