import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class TVButton extends StatefulWidget {
  final Widget child; final VoidCallback onTap; final double radius;
  const TVButton({super.key, required this.child, required this.onTap, this.radius = 20});
  @override State<TVButton> createState() => _TVButtonState();
}
class _TVButtonState extends State<TVButton> {
  bool _isF = false;
  @override Widget build(BuildContext context) {
    return Focus(onFocusChange: (f)=>setState(()=>_isF=f), onKeyEvent: (n,e){
      if(e is KeyDownEvent && (e.logicalKey == LogicalKeyboardKey.select || e.logicalKey == LogicalKeyboardKey.enter)){
        widget.onTap(); return KeyEventResult.handled;
      } return KeyEventResult.ignored;
    }, child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 150), decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.radius), border: Border.all(color: _isF ? const Color(0xFF00D9FF) : Colors.transparent, width: 3.0), boxShadow: _isF ? [BoxShadow(color: const Color(0xFF00D9FF).withOpacity(0.5), blurRadius: 15)] : []), transform: _isF ? (Matrix4.identity()..scale(1.04)) : Matrix4.identity(), child: widget.child)));
  }
}
