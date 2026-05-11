import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../shared/widgets.dart';
import '../player/player_screen.dart';

class TVHome extends ConsumerWidget {
  const TVHome({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ds = ref.watch(dramasProvider);
    final bn = ref.watch(bannerProvider);
    final selP = ref.watch(platformProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF05070D),
      body: Row(children: [
        // Sidebar Ikon Paten
        Container(width: 80, color: const Color(0xFF161B22), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(Icons.home, color: Color(0xFF00D9FF), size: 30), SizedBox(height: 40),
          Icon(Icons.history, color: Colors.grey, size: 30), SizedBox(height: 40),
          Icon(Icons.favorite, color: Colors.grey, size: 30)
        ])),
        Expanded(child: SingleChildScrollView(child: Column(children: [
          bn.when(data: (d)=>d==null?const SizedBox():_banner(context, d, selP), loading: ()=>const SizedBox(height: 250), error: (_,__)=>const SizedBox()),
          _chips(ref, selP),
          ds.when(data: (list)=>GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.65, mainAxisSpacing: 15, crossAxisSpacing: 15), itemCount: list.length, itemBuilder: (c, i) => TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: list[i]['id'], source: selP, title: list[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(list[i]['cover'], fit: BoxFit.cover)))), loading: ()=>const CircularProgressIndicator(), error: (_,__)=>const SizedBox())
        ])))
      ]),
    );
  }
  Widget _banner(BuildContext ctx, Map d, String p) => Container(margin: const EdgeInsets.all(20), height: 260, decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.network(d['cover'], fit: BoxFit.cover, width: double.infinity)), Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: LinearGradient(begin: Alignment.centerRight, colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.9)]))), Padding(padding: const EdgeInsets.all(30), child: Row(children: [Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text(d['synopsis']??"", maxLines: 2, style: const TextStyle(color: Colors.grey))])), const SizedBox(width: 20), TVButton(onTap: ()=>Navigator.push(ctx, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: d['id'], source: p, title: d['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(d['cover'], width: 150, fit: BoxFit.cover)))]))]));
  Widget _chips(WidgetRef ref, String s) => SizedBox(height: 60, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 20), children: ["Melolo","FreeReels","FlickReels","RapidTV","DramaBox"].map((p)=>Padding(padding: const EdgeInsets.only(right: 15), child: TVButton(onTap: ()=>ref.read(platformProvider.notifier).state=p.toLowerCase(), child: Container(padding: const EdgeInsets.symmetric(horizontal: 30), alignment: Alignment.center, decoration: BoxDecoration(color: s==p.toLowerCase()?const Color(0xFF8B5CF6):Colors.white10, borderRadius: BorderRadius.circular(15)), child: Text(p, style: const TextStyle(fontWeight: FontWeight.bold)))))).toList()));
}
