import 'package:flutter/material.dart';
import '../../shared/widgets.dart';
class TVSidebar extends StatelessWidget {
  final int sel; final Function(int) onSel;
  const TVSidebar({super.key, required this.sel, required this.onSel});
  @override Widget build(BuildContext context) {
    return Container(width: 80, color: const Color(0xFF161B22), child: Column(children: [
      const SizedBox(height: 35),
      TVButton(onTap:(){}, child: const CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white))),
      const Spacer(),
      _i(0, Icons.home_filled), _i(1, Icons.download), _i(2, Icons.history), _i(3, Icons.favorite), _i(4, Icons.person), _i(5, Icons.search),
      const SizedBox(height: 30),
    ]));
  }
  Widget _i(int index, IconData ico) => Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: TVButton(onTap: ()=>onSel(index), child: Icon(ico, color: sel == index ? const Color(0xFF00D9FF) : Colors.white24)));
}
