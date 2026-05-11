import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/app_providers.dart';
import '../player/player_screen.dart';

class MobileHome extends ConsumerWidget {
  const MobileHome({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dramas = ref.watch(dramasProvider);
    final selP = ref.watch(platformProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF05070D),
      appBar: AppBar(backgroundColor: const Color(0xFF161B22), title: const Text("LiveGo Streaming", style: TextStyle(color: Color(0xFF00D9FF), fontWeight: FontWeight.bold))),
      body: dramas.when(
        data: (list) => GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.62, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemCount: list.length,
          itemBuilder: (c, i) => InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (x) => LiveGoPlayer(id: list[i]['id'], source: selP, title: list[i]['title']))),
            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: list[i]['cover'], fit: BoxFit.cover)),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF))),
        error: (e, s) => const Center(child: Text("Gagal memuat data")),
      ),
    );
  }
}
