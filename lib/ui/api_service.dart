import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String secret = "22dfb2b849814054af0491ff2ee3ffe33989313d7d38e97aae659757a4cf8960";
  static const String base = "https://api-drama.dobda.id";

  static Future<dynamic> get(String path) async {
    String ts = DateTime.now().millisecondsSinceEpoch.toString();
    String payload = "GET:$path:$ts";
    var sig = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(payload)).toString();
    try {
      final r = await http.get(Uri.parse(base + path), headers: {"X-Timestamp": ts, "X-Signature": sig});
      return json.decode(r.body);
    } catch (e) { return null; }
  }
}
