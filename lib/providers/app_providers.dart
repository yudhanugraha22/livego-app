import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_engine.dart';
import '../core/storage.dart';

final platformProvider = StateProvider<String>((ref) => "melolo");
final dramasProvider = FutureProvider<List>((ref) async {
  final plat = ref.watch(platformProvider);
  final res = await ApiEngine.request("/api/v2/home?category_p=$plat&lang=id");
  return res != null ? res['data'] : [];
});
final historyProvider = FutureProvider<List>((ref) async {
  // Simulasi tabel watch_history
  return []; 
});
