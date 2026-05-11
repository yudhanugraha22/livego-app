import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../providers/app_providers.dart';
import '../player/player_screen.dart';
import '../shared/widgets.dart';

class MobileHome extends ConsumerWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ds = ref.watch(dramasProvider);
    final banners = ref.watch(bannerProvider);
    final selP = ref.watch(platformProvider);
    final selC = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF05070D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF05070D), elevation: 0,
        title: const Text("LiveGo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF00D9FF))),
        actions: [const Icon(Icons.history), const SizedBox(width:15), const Icon(Icons.favorite_border), const SizedBox(width:15), const Icon(Icons.search), const SizedBox(width:15)],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // 1. DYNAMIC BANNER SLIDER
          banners.when(
            data: (list) => list.isEmpty ? const SizedBox() : _BannerSlider(items: list, platform: selP),
            loading: () => const Container(height: 210, child: Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF)))),
            error: (_, __) => const SizedBox(),
          ),

          const Divider(color: Colors.white10, indent: 15, endIndent: 15),

          // 2. CHIPS SELECTOR
          _chips(ref, ["Melolo","FreeReels","FlickReels","RapidTV"], selP, true),
          const SizedBox(height: 8),
          _chips(ref, ["Dubbing","Populer","New","Trending"], selC, false),

          // 3. GRID CONTENT
          ds.when(
            data: (list) => GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.62, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemCount: list.length,
              itemBuilder: (c, i) => TVButton(radius: 12, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (x)=>LiveGoPlayer(id: list[i]['id'], source: selP, title: list[i]['title']))), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(list[i]['cover'], fit: BoxFit.cover))),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF))),
            error: (_, __) => const Text("Error Load Data"),
          ),
        ]),
      ),
    );
  }

  Widget _chips(WidgetRef ref, List<String> l, String s, bool isP) => SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 15), itemCount: l.length, itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.only(right: 8), child: TVButton(radius: 20, onTap: (){ isP ? ref.read(platformProvider.notifier).state=l[i].toLowerCase() : ref.read(categoryProvider.notifier).state=l[i]; }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 22), alignment: Alignment.center, decoration: BoxDecoration(color: s.toLowerCase()==l[i].toLowerCase()||s==l[i]?(isP?const Color(0xFF8B5CF6):const Color(0xFF00D9FF)):Colors.white10, borderRadius: BorderRadius.circular(25)), child: Text(l[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))))));
}

// COMPONENT: BANNER SLIDER
class _BannerSlider extends StatefulWidget {
  final List items;
  final String platform;
  const _BannerSlider({required this.items, required this.platform});
  @override State<_BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<_BannerSlider> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final d = widget.items[index];
              return _buildItem(d);
            },
          ),
        ),
        const SizedBox(height: 8),
        // Indicator Titik (Dots)
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(widget.items.length > 5 ? 5 : widget.items.length, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: _currentPage == i ? 12 : 6, height: 6, decoration: BoxDecoration(color: _currentPage == i ? const Color(0xFF00D9FF) : Colors.white24, borderRadius: BorderRadius.circular(10))))),
      ],
    );
  }

  Widget _buildItem(Map d) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white10, width: 1.5)),
      child: Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.network(d['cover'], fit: BoxFit.cover, width: double.infinity)),
        Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft, colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.9)]))),
        Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          Expanded(flex: 2, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(5)), child: Text(widget.platform.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Text(d['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2),
            const SizedBox(height: 5),
            Text(d['synopsis'] ?? "", maxLines: 2, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ])),
          const SizedBox(width: 10),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(d['cover'], fit: BoxFit.cover))),
        ]))
      ]),
    );
  }
}
