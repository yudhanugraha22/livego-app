import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

class MobileHome extends ConsumerWidget {
  const MobileHome({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dramas = ref.watch(homeDataProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(title: const Text("Livego Mobile"), backgroundColor: const Color(0xFF161B22)),
      body: dramas.when(
        data: (list) => GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.65, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemCount: list.length,
          itemBuilder: (c, i) => ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(list[i]['cover'], fit: BoxFit.cover)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const Center(child: Text("Gagal memuat data")),
      ),
    );
  }
}
