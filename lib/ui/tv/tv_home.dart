import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/app_providers.dart';
import '../shared/widgets.dart';
import '../player/player_screen.dart';

class TVHome extends ConsumerWidget {
  const TVHome({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dramas = ref.watch(dramasProvider);
    final selP = ref.watch(platformProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF05070D),
      body: Row(children: [
        // Sidebar Ikon (Identik CineFlow)
        Container(width: 80, color: const Color(0xFF161B22), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(Icons.home, color: Color(0xFF00D9FF), size: 30), SizedBox(height: 40),
          Icon(Icons.history, color: Colors.grey, size: 30), SizedBox(height: 40),
          Icon(Icons.person, color: Colors.grey, size: 30)
        ])),
        Expanded(child: Column(children: [
          _chips(ref, selP),
          Expanded(child: dramas.when(
            data: (list) => GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.65, mainAxisSpacing: 15, crossAxisSpacing: 15),
              itemCount: list.length,
              itemBuilder: (c, i) => TVButton(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (x) => LiveGoPlayer(id: list[i]['id'], source: selP, title: list[i]['title']))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(imageUrl: list[i]['cover'], fit: BoxFit.cover, placeholder: (c,u) => Container(color: Colors.white10)),
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF))),
            error: (e, s) => const Center(child: Text("Error API")),
          )),
        ])),
      ]),
    );
  }
  Widget _chips(WidgetRef ref, String s) => SizedBox(height: 80, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 20), children: ["Melolo","FreeReels","FlickReels","RapidTV"].map((p)=>Padding(padding: const EdgeInsets.only(right: 15, top: 15, bottom: 15), child: TVButton(onTap: ()=>ref.read(platformProvider.notifier).state=p.toLowerCase(), child: Container(padding: const EdgeInsets.symmetric(horizontal: 35), alignment: Alignment.center, decoration: BoxDecoration(color: s==p.toLowerCase()?const Color(0xFF8B5CF6):Colors.white10, borderRadius: BorderRadius.circular(15)), child: Text(p, style: const TextStyle(fontWeight: FontWeight.bold)))))).toList()));
}
