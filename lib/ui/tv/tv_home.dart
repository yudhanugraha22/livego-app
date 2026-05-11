import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_providers.dart';
import '../../shared/widgets.dart';
import '../player/player_screen.dart';

class TVHome extends ConsumerWidget {
  const TVHome({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final dramas = ref.watch(dramasProvider);
    final selP = ref.watch(platformProvider);
    return Scaffold(backgroundColor: const Color(0xFF05070D), body: Row(children: [
      Container(width: 70, color: const Color(0xFF161B22), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.home, color: Color(0xFF00D9FF), size: 30), SizedBox(height: 40), Icon(Icons.person, color: Colors.grey, size: 30)])),
      Expanded(child: Column(children: [
        SizedBox(height: 70, child: ListView(scrollDirection: Axis.horizontal, children: ["Melolo","FreeReels","FlickReels","RapidTV"].map((p)=>Padding(padding: const EdgeInsets.all(10), child: TVButton(onTap: ()=>ref.read(platformProvider.notifier).state=p.toLowerCase(), child: Container(padding: const EdgeInsets.symmetric(horizontal: 30), alignment: Alignment.center, decoration: BoxDecoration(color: selP==p.toLowerCase()?const Color(0xFF8B5CF6):Colors.white10, borderRadius: BorderRadius.circular(15)), child: Text(p, style: const TextStyle(fontWeight: FontWeight.bold)))))).toList())),
        Expanded(child: dramas.when(data: (list)=>GridView.builder(padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.65, mainAxisSpacing: 15, crossAxisSpacing: 15), itemCount: list.length, itemBuilder: (c, i) => TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: list[i]['id'], source: selP, title: list[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(list[i]['cover'], fit: BoxFit.cover)))), loading: ()=>const Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF))), error: (_,__)=>const SizedBox()))
      ]))
    ]));
  }
}
