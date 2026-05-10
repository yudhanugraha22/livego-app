import 'package:flutter/material.dart';

class TvPlayerDialog extends StatefulWidget {
  final String title;
  final List<String> options;
  final String currentValue;
  final Function(String) onSelected;

  const TvPlayerDialog({
    super.key,
    required this.title,
    required this.options,
    required this.currentValue,
    required this.onSelected,
  });

  @override
  State<TvPlayerDialog> createState() => _TvPlayerDialogState();
}

class _TvPlayerDialogState extends State<TvPlayerDialog> {
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    final index = widget.options.indexOf(widget.currentValue);
    if (index != -1) {
      _focusedIndex = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF131026),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Color(0xFF00D9FF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                final option = widget.options[index];
                final isSelected = option == widget.currentValue;
                final isFocused = _focusedIndex == index;

                return InkWell(
                  onFocusChange: (hasFocus) {
                    if (hasFocus) {
                      setState(() {
                        _focusedIndex = index;
                      });
                    }
                  },
                  onTap: () {
                    widget.onSelected(option);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isFocused ? const Color(0xFF00D9FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            color: isFocused ? Colors.black : Colors.white,
                            fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: isFocused ? Colors.black : const Color(0xFF00D9FF),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
