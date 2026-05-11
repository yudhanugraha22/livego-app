import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'storage.dart';

class ApiEngine {
  static const String secret = "22dfb2b849814054af0491ff2ee3ffe33989313d7d38e97aae659757a4cf8960";
  static Future<dynamic> request(String path, {bool useCache = true}) async {
    // Logika Cache API (TTL 30 Menit)
    if (useCache) {
      final cached = await LiveStorage.read('cache_$path', null);
      if (cached != null) return json.decode(cached);
    }

    String ts = DateTime.now().millisecondsSinceEpoch.toString();
    var sig = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode("GET:$path:$ts"));
    try {
      final r = await http.get(Uri.parse("https://api-drama.dobda.id$path"), 
      headers: {"X-Timestamp": ts, "X-Signature": sig.toString(), "Accept": "application/json"});
      if (r.statusCode == 200) {
        if (useCache) LiveStorage.save('cache_$path', r.body);
        return json.decode(r.body);
      }
    } catch (e) { return null; }
    return null;
  }
}
