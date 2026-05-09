import 'package:flutter/material.dart';

class TVButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double borderRadius; // Tambahkan ini
  const TVButton({super.key, required this.child, required this.onTap, this.borderRadius = 15});

  @override State<TVButton> createState() => _TVButtonState();
}

class _TVButtonState extends State<TVButton> {
  bool _isF = false;
  @override Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isF = f),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius), // Gunakan variabel di sini
            border: Border.all(color: _isF ? Colors.blueAccent : Colors.transparent, width: 3.0),
            boxShadow: _isF ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.7), blurRadius: 15)] : [],
          ),
          transform: _isF ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
          child: widget.child,
        ),
      ),
    );
  }
}
