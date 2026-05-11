import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_engine.dart';
import '../core/storage_engine.dart';
final platformProvider = StateProvider<String>((ref) => "melolo");
final categoryProvider = StateProvider<String>((ref) => "Dubbing");
final dramasProvider = FutureProvider<List>((ref) async {
  final plat = ref.watch(platformProvider);
  final cat = ref.watch(categoryProvider);
  String p = (cat == "Dubbing") ? "/api/v2/search?category_p=$plat&q=sulih suara&lang=id" : "/api/v2/home?category_p=$plat&lang=id";
  final res = await ApiEngine.request(p);
  return res != null ? res['data'] : [];
});
final bannerProvider = FutureProvider<Map?>((ref) async {
  final plat = ref.watch(platformProvider);
  final res = await ApiEngine.request("/api/v2/banner?category_p=$plat&lang=id");
  return (res != null && res['data'].isNotEmpty) ? res['data'][0] : null;
});
