import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TvSidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRequestFocusContent;

  const TvSidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.onRequestFocusContent,
  });

  @override
  State<TvSidebarItem> createState() => _TvSidebarItemState();
}

class _TvSidebarItemState extends State<TvSidebarItem> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          // Jika tombol kanan (→) ditekan, pindah fokus ke konten utama
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            widget.onRequestFocusContent();
            return KeyEventResult.handled;
          }
          // Jika tombol OK ditekan, jalankan aksi menu
          if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: _isFocused 
              ? const Color(0xFF00D9FF) 
              : widget.isSelected 
                  ? Colors.white12 
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D9FF).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: _isFocused 
                  ? Colors.black 
                  : widget.isSelected 
                      ? const Color(0xFF00D9FF) 
                      : Colors.white70,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: _isFocused 
                      ? Colors.black 
                      : widget.isSelected 
                          ? Colors.white 
                          : Colors.white70,
                  fontSize: 14,
                  fontWeight: _isFocused || widget.isSelected 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
