import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../shared/widgets.dart';
import 'widgets/tv_sidebar.dart';
import '../player/player_screen.dart';
class TVHome extends ConsumerStatefulWidget {
  const TVHome({super.key});
  @override ConsumerState<TVHome> createState() => _TVHomeState();
}
class _TVHomeState extends ConsumerState<TVHome> {
  int sideIdx = 0;
  @override Widget build(BuildContext context) {
    final dramas = ref.watch(dramasProvider);
    final banners = ref.watch(bannerProvider);
    final selP = ref.watch(platformProvider);
    return Scaffold(backgroundColor: const Color(0xFF0D1117), body: Row(children: [
      TVSidebar(sel: sideIdx, onSel: (i)=>setState(()=>sideIdx=i)),
      Expanded(child: SingleChildScrollView(child: Column(children: [
        const SizedBox(height: 20),
        banners.when(data: (list)=>list.isEmpty?const SizedBox():_slider(list, selP), loading: ()=>const SizedBox(height: 250), error: (_,__)=>const SizedBox()),
        _chips(ref, selP),
        dramas.when(data: (list)=>GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.65, mainAxisSpacing: 15, crossAxisSpacing: 15), itemCount: list.length, itemBuilder: (c, i) => TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: list[i]['id'], source: selP, title: list[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(list[i]['cover'], fit: BoxFit.cover)))), loading: ()=>const Center(child: CircularProgressIndicator()), error: (e,s)=>const SizedBox())
      ])))
    ]));
  }
  Widget _slider(List items, String p) => Container(height: 280, margin: const EdgeInsets.symmetric(horizontal: 20), child: PageView.builder(itemCount: items.length, itemBuilder: (ctx, i) => _b(items[i], p)));
  Widget _b(Map d, String p) => TVButton(radius: 28, onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: d['id'], source: p, title: d['title']))), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.network(d['cover'], fit: BoxFit.cover, width: double.infinity)), Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: LinearGradient(begin: Alignment.centerRight, colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.9)]))), Padding(padding: const EdgeInsets.all(30), child: Row(children: [Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d['title'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text(d['synopsis']??"", maxLines: 2, style: const TextStyle(color: Colors.grey, fontSize: 14))])), const SizedBox(width: 20), ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(d['cover'], width: 160, fit: BoxFit.cover))]))]));
  Widget _chips(WidgetRef ref, String s) => SizedBox(height: 70, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 20), children: ["Melolo","FreeReels","FlickReels","RapidTV"].map((p)=>Padding(padding: const EdgeInsets.only(right: 15), child: TVButton(onTap: ()=>ref.read(platformProvider.notifier).state=p.toLowerCase(), child: Container(padding: const EdgeInsets.symmetric(horizontal: 35), alignment: Alignment.center, decoration: BoxDecoration(color: s==p.toLowerCase()?const Color(0xFF8B5CF6):Colors.white10, borderRadius: BorderRadius.circular(20)), child: Text(p, style: const TextStyle(fontWeight: FontWeight.bold)))))).toList()));
}
