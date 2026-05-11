import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class ApiEngine {
  static const String apiKey = "59756468614e756772616861";
  static const String secret = "22dfb2b849814054af0491ff2ee3ffe33989313d7d38e97aae659757a4cf8960";
  static const String baseUrl = "https://api-drama.dobda.id";

  static Future<dynamic> request(String path) async {
    String ts = DateTime.now().millisecondsSinceEpoch.toString();
    // Rumus HMAC V2 sesuai dokumen: GET:/path:timestamp
    String payload = "GET:$path:$ts";
    var sig = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(payload));

    try {
      final r = await http.get(Uri.parse("$baseUrl$path"), 
      headers: {
        "X-Timestamp": ts, 
        "X-Signature": sig.toString(),
        "Accept": "application/json"
      });
      return r.statusCode == 200 ? json.decode(r.body) : null;
    } catch (e) { return null; }
  }
}
