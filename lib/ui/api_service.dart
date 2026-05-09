import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
class ApiService {
  static const String baseUrl = "https://api-drama.dobda.id";
  static const String secret = "22dfb2b849814054af0491ff2ee3ffe33989313d7d38e97aae659757a4cf8960";
  static Future<dynamic> get(String path) async {
    String ts = DateTime.now().millisecondsSinceEpoch.toString();
    var sig = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode("GET:$path:$ts"));
    try {
      final r = await http.get(Uri.parse(baseUrl + path), headers: {"X-Timestamp": ts, "X-Signature": sig.toString()});
      if (r.statusCode == 200) return json.decode(r.body);
    } catch (e) { return null; }
    return null;
  }
}
