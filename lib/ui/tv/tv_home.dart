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
    final banner = ref.watch(bannerProvider);
    final selP = ref.watch(platformProvider);
    return Scaffold(backgroundColor: const Color(0xFF0D1117), body: Row(children: [
      TVSidebar(sel: sideIdx, onSel: (i)=>setState(()=>sideIdx=i)),
      Expanded(child: SingleChildScrollView(child: Column(children: [
        banner.when(data: (d)=>d==null?const SizedBox():Container(margin: const EdgeInsets.all(20), height: 260, decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)), child: Image.network(d['cover'], fit: BoxFit.cover, width: double.infinity)), loading: ()=>const SizedBox(height: 200), error: (_,__)=>const SizedBox()),
        dramas.when(data: (list)=>GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.65, mainAxisSpacing: 15, crossAxisSpacing: 15), itemCount: list.length, itemBuilder: (c, i) => TVButton(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: list[i]['id'], source: selP, title: list[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(list[i]['cover'], fit: BoxFit.cover)))), loading: ()=>const Center(child: CircularProgressIndicator()), error: (e,s)=>const SizedBox())
      ])))
    ]));
  }
}
