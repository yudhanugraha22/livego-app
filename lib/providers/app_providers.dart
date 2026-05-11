import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_engine.dart';

final platformProvider = StateProvider<String>((ref) => "melolo");
final categoryProvider = StateProvider<String>((ref) => "dub-indo");

final dramasProvider = FutureProvider<List>((ref) async {
  final plat = ref.watch(platformProvider);
  final cat = ref.watch(categoryProvider);
  
  // Logika Filter: Jika Dubbing pakai endpoint Search, jika lain pakai Home
  String path = (cat == "dub-indo") 
    ? "/api/v2/search?category_p=$plat&q=sulih suara&lang=id" 
    : "/api/v2/home?category_p=$plat&lang=id";
    
  final res = await ApiEngine.request(path);
  return res != null ? res['data'] : [];
});

final bannerProvider = FutureProvider<Map?>((ref) async {
  final plat = ref.watch(platformProvider);
  final res = await ApiEngine.request("/api/v2/banner?category_p=$plat&lang=id");
  return (res != null && res['data'].isNotEmpty) ? res['data'][0] : null;
});
