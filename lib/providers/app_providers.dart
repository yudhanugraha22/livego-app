import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_engine.dart';

final platformProvider = StateProvider<String>((ref) => "melolo");
final categoryProvider = StateProvider<String>((ref) => "Dubbing");

final homeDataProvider = FutureProvider<List>((ref) async {
  final plat = ref.watch(platformProvider);
  final cat = ref.watch(categoryProvider);
  String path = (cat == "Dubbing") 
    ? "/api/v2/search?category_p=$plat&q=sulih suara&lang=id" 
    : "/api/v2/home?category_p=$plat&lang=id";
  final res = await ApiEngine.request(path);
  return res != null ? res['data'] : [];
});
