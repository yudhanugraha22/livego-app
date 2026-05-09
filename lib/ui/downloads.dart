import 'package:flutter/material.dart';
import 'widgets.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: const Text("CineFlow", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // BOX INFO PENYIMPANAN (SESUAI GAMBAR)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Koleksi Unduhan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("Tidak ada file tersimpan", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 15),
                  Row(children: [
                    _badge("0 koleksi"),
                    const SizedBox(width: 10),
                    _badge("0 siap"),
                  ]),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(children: [Icon(Icons.download_for_offline, size: 16, color: Colors.blueAccent), SizedBox(width: 5), Text("Penyimpanan offline", style: TextStyle(fontSize: 12))]),
                      Text("46%", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: const LinearProgressIndicator(value: 0.46, backgroundColor: Colors.white12, color: Color(0xFF8B5CF6)),
                  ),
                  const SizedBox(height: 5),
                  const Text("Tersisa 118,9 GB dari 224 GB", style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // EMPTY STATE (SESUAI GAMBAR)
            Column(
              children: [
                Icon(Icons.file_download_outlined, size: 100, color: Colors.blueAccent.withOpacity(0.5)),
                const SizedBox(height: 20),
                const Text("Belum ada unduhan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Simpan judul favorit Anda dan buka lagi kapan saja tanpa koneksi.", 
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
    child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
  );
}
