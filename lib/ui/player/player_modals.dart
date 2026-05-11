import 'package:flutter/material.dart';

class PlayerModals {
  static void showQuality(BuildContext context, String current, Function(String) onSelect) {
    _show(context, "Pilih Kualitas", ["Auto", "1080p", "720p", "540p", "360p"], current, onSelect);
  }

  static void showAudio(BuildContext context, String current, Function(String) onSelect) {
    _show(context, "Pilih Audio", ["id-ID Stereo", "Mandarin Stereo"], current, onSelect);
  }

  static void showSubtitle(BuildContext context, String current, Function(String) onSelect) {
    _show(context, "Pilih Subtitle", ["Matikan", "Indonesia", "Inggris", "Spanyol", "Portugis", "Jerman", "Prancis", "Rusia", "Italia"], current, onSelect);
  }

  static void _show(BuildContext context, String title, List<String> options, String current, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF121820),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
        title: Center(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((o) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: current == o ? const Color(0xFF00D9FF) : Colors.white10),
              color: current == o ? const Color(0xFF00D9FF).withOpacity(0.1) : Colors.transparent,
            ),
            child: ListTile(
              title: Text(o, style: TextStyle(color: current == o ? const Color(0xFF00D9FF) : Colors.white, fontSize: 14)),
              trailing: current == o ? const Icon(Icons.play_arrow, color: Color(0xFF00D9FF), size: 18) : null,
              onTap: () { onSelect(o); Navigator.pop(c); },
            ),
          )).toList(),
        ),
      ),
    );
  }
}
