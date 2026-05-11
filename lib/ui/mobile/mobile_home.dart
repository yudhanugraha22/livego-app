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
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(backgroundColor: const Color(0xFF161B22), elevation: 0, title: const Text("LiveGo", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00D9FF)))),
      body: SingleChildScrollView(child: Column(children: [
        const SizedBox(height: 10),
        bn.when(data: (d)=> d == null ? const SizedBox() : _bannerUI(context, d, selP), loading: ()=>const Center(child: CircularProgressIndicator()), error: (_,__) => const Text("Banner Error")),
        const Divider(color: Colors.white10, indent: 15, endIndent: 15),
        _chips(ref, ["Melolo","FreeReels","FlickReels","RapidTV"], selP, true),
        _chips(ref, ["Dubbing","Populer","New","Trending"], selC, false),
        ds.when(
          data: (list) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(15), 
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.6, mainAxisSpacing: 10, crossAxisSpacing: 10),
            itemCount: list.length, itemBuilder: (c, i) => TVButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: list[i]['id'], source: selP, title: list[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(list[i]['cover'], fit: BoxFit.cover)))),
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())),
          error: (e, __) => Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Error: $e", style: const TextStyle(color: Colors.red, fontSize: 10)))),
        )
      ])),
    );
  }
  Widget _bannerUI(BuildContext ctx, Map d, String p) => Container(margin: const EdgeInsets.all(15), height: 180, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(d['cover'], fit: BoxFit.cover, width: double.infinity)), Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black, Colors.transparent]))), Padding(padding: const EdgeInsets.all(15), child: Text(d['title'], style: const TextStyle(fontWeight: FontWeight.bold)))]));
  Widget _chips(WidgetRef ref, List<String> l, String s, bool isP) => SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: l.length, itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.only(right: 8), child: TVButton(onTap: (){ isP ? ref.read(platformProvider.notifier).state=l[i].toLowerCase() : ref.read(categoryProvider.notifier).state=l[i]; }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: s.toLowerCase()==l[i].toLowerCase()||s==l[i] ? (isP?const Color(0xFF8B5CF6):const Color(0xFF00D9FF)) : Colors.white10, borderRadius: BorderRadius.circular(20)), alignment: Alignment.center, child: Text(l[i]))))));
}
