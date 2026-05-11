import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_engine.dart';
final platformProvider = StateProvider<String>((ref) => "melolo");
final dramasProvider = FutureProvider<List>((ref) async {
  final plat = ref.watch(platformProvider);
  final res = await ApiEngine.request("/api/v2/home?category_p=$plat&lang=id");
  if (res != null && res['success'] == true) return res['data'];
  return [];
});
final bannerProvider = FutureProvider<List>((ref) async {
  final plat = ref.watch(platformProvider);
  final res = await ApiEngine.request("/api/v2/banner?category_p=$plat&lang=id");
  if (res != null && res['success'] == true) return res['data'];
  return [];
});
