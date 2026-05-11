import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../widgets/poster_card.dart';

class MobileHome extends ConsumerWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dramas = ref.watch(homeDataProvider);
    final banner = ref.watch(bannerProvider);
    final selPlat = ref.watch(platformProvider);
    final selCat = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: const Text("LiveGO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.history, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // Banner Mewah
          banner.when(
            data: (data) => data == null ? const SizedBox() : _buildBanner(data),
            loading: () => const SizedBox(height: 200),
            error: (_, __) => const SizedBox(),
          ),
          const Divider(color: Colors.white10, indent: 15, endIndent: 15),
          // Platform Selector (Ungu)
          _buildChipList(ref, ["Melolo", "FreeReels", "FlickReels", "RapidTV"], selPlat, true),
          const SizedBox(height: 10),
          // Category Selector (Biru Gradient)
          _buildChipList(ref, ["Dubbing", "Populer", "New", "Trending"], selCat, false),
          const SizedBox(height: 15),
          // Grid 4 Kolom
          dramas.when(
            data: (list) => GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.6, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemCount: list.length,
              itemBuilder: (c, i) => PosterCard(item: list[i], onTap: () {}),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
            error: (e, s) => const Center(child: Text("Gagal memuat data")),
          ),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildBanner(Map data) {
    return Container(
      margin: const EdgeInsets.all(15), height: 180,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
      child: Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.network(data['cover'], fit: BoxFit.cover, width: double.infinity)),
        Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: LinearGradient(begin: Alignment.centerRight, colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.9)]))),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Expanded(flex: 2, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2),
              const SizedBox(height: 5),
              Text(data['synopsis'] ?? "", maxLines: 2, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ])),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(data['cover'], fit: BoxFit.cover))),
          ]),
        )
      ]),
    );
  }

  Widget _buildChipList(WidgetRef ref, List<String> list, String selected, bool isPlat) {
    return SizedBox(height: 40, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: list.length, itemBuilder: (ctx, i) => Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ActionChip(
        label: Text(list[i], style: const TextStyle(fontSize: 12)),
        backgroundColor: selected.toLowerCase() == list[i].toLowerCase() ? (isPlat ? const Color(0xFF8B5CF6) : Colors.blueAccent) : Colors.white10,
        onPressed: () => isPlat ? ref.read(platformProvider.notifier).state = list[i].toLowerCase() : ref.read(categoryProvider.notifier).state = list[i],
      ),
    )));
  }
}
