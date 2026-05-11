import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_providers.dart';
import '../player/player_screen.dart';
import '../shared/widgets.dart';

class MobileHome extends ConsumerWidget {
  const MobileHome({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ds = ref.watch(dramasProvider);
    final bn = ref.watch(bannerProvider);
    final selP = ref.watch(platformProvider);
    final selC = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF05070D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF05070D), elevation: 0,
        title: const Text("LiveGo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        actions: [const Icon(Icons.history), const SizedBox(width:15), const Icon(Icons.favorite_border), const SizedBox(width:15), const Icon(Icons.search), const SizedBox(width:15)],
      ),
      body: SingleChildScrollView(child: Column(children: [
        bn.when(data: (d)=>d==null?const SizedBox():_buildBanner(context, d, selP), loading: ()=>const SizedBox(height: 200), error: (_,__) => const SizedBox()),
        const Divider(color: Colors.white10, indent: 15, endIndent: 15),
        _chips(ref, ["Melolo","FreeReels","FlickReels","RapidTV"], selP, true),
        const SizedBox(height: 8),
        _chips(ref, ["Dubbing","Populer","New","Trending"], selC, false),
        const SizedBox(height: 15),
        ds.when(data: (list)=>GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.6, mainAxisSpacing: 10, crossAxisSpacing: 10), itemCount: list.length, itemBuilder: (c,i)=>_poster(context, list[i], selP)), loading: ()=>const Center(child: CircularProgressIndicator()), error: (_,__) => const Text("API Error")),
      ])),
    );
  }

  Widget _buildBanner(BuildContext ctx, Map d, String p) => Container(
    margin: const EdgeInsets.all(15), height: 210,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white10, width: 1.5)),
    child: Stack(children: [
      ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.network(d['cover'], fit: BoxFit.cover, width: double.infinity)),
      Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft, colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.9)]))),
      Padding(padding: const EdgeInsets.all(20), child: Row(children: [
        Expanded(flex: 2, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(5)), child: Text(p.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          Text(d['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2),
          const SizedBox(height: 5),
          Text(d['synopsis'] ?? "", maxLines: 2, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ])),
        const SizedBox(width: 10),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(d['cover'], fit: BoxFit.cover))),
      ]))
    ]),
  );

  Widget _chips(WidgetRef ref, List<String> l, String s, bool isP) => SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: l.length, itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.only(right: 10), child: TVButton(radius: 25, onTap: (){ isP?ref.read(platformProvider.notifier).state=l[i].toLowerCase():ref.read(categoryProvider.notifier).state=l[i]; }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 22), alignment: Alignment.center, decoration: BoxDecoration(color: s.toLowerCase()==l[i].toLowerCase()||s==l[i]?(isP?const Color(0xFF8B5CF6):const Color(0xFF00D9FF)):Colors.white10, borderRadius: BorderRadius.circular(25)), child: Text(l[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))))));

  Widget _poster(BuildContext ctx, Map d, String p) => TVButton(radius: 12, onTap: ()=>Navigator.push(ctx, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: d['id'], source: p, title: d['title']))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Stack(children: [
      Image.network(d['cover'], fit: BoxFit.cover, width: double.infinity),
      Positioned(top: 5, left: 5, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)), child: Text("${d['chapters']} Ep", style: const TextStyle(fontSize: 8)))),
      Positioned(top: 5, right: 5, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)), child: Text(d['views'] ?? "0", style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))),
    ]))),
    const SizedBox(height: 5),
    Text(d['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
  ]));
}
