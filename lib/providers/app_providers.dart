import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_engine.dart';
final platformProvider = StateProvider<String>((ref) => "melolo");
final categoryProvider = StateProvider<String>((ref) => "Dubbing");
final dramasProvider = FutureProvider<List>((ref) async {
  final p = ref.watch(platformProvider);
  final c = ref.watch(categoryProvider);
  String path = (c == "Dubbing") ? "/api/v2/search?category_p=$p&q=sulih suara&lang=id" : "/api/v2/home?category_p=$p&lang=id";
  final res = await ApiEngine.request(path);
  if (res != null && res['success'] == true) return res['data'];
  throw res?['message'] ?? "Gagal muat data";
});
final bannerProvider = FutureProvider<Map?>((ref) async {
  final p = ref.watch(platformProvider);
  final res = await ApiEngine.request("/api/v2/banner?category_p=$p&lang=id");
  return (res != null && res['success'] == true && res['data'].isNotEmpty) ? res['data'][0] : null;
});
