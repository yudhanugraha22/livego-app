import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResumePromptDialog extends StatefulWidget {
  final String title;
  final String formattedTime;
  final VoidCallback onResume;
  final VoidCallback onRestart;

  const ResumePromptDialog({
    super.key,
    required this.title,
    required this.formattedTime,
    required this.onResume,
    required this.onRestart,
  });

  @override
  State<ResumePromptDialog> createState() => _ResumePromptDialogState();
}

class _ResumePromptDialogState extends State<ResumePromptDialog> {
  int _focusedIndex = 0; // 0 = Lanjutkan, 1 = Ulangi

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF131026),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.history, color: Color(0xFF00D9FF), size: 36),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Anda sudah menonton episode ini sampai menit ke- ${widget.formattedTime}.",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tombol Ulangi dari Awal
                InkWell(
                  onFocusChange: (hasFocus) {
                    if (hasFocus) setState(() => _focusedIndex = 1);
                  },
                  onTap: () {
                    Navigator.pop(context);
                    widget.onRestart();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _focusedIndex == 1 ? const Color(0xFFFF007F) : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Mulai dari Awal",
                      style: TextStyle(
                        color: _focusedIndex == 1 ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Lanjutkan Menonton
                InkWell(
                  onFocusChange: (hasFocus) {
                    if (hasFocus) setState(() => _focusedIndex = 0);
                  },
                  onTap: () {
                    Navigator.pop(context);
                    widget.onResume();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _focusedIndex == 0 ? const Color(0xFF00D9FF) : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Lanjutkan (${widget.formattedTime})",
                      style: TextStyle(
                        color: _focusedIndex == 0 ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
