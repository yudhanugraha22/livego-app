import 'package:flutter/material.dart';

class PosterCard extends StatelessWidget {
  final Map item;
  final VoidCallback onTap;
  const PosterCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.network(item['cover'], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  // Badge EP (Kiri Atas)
                  Positioned(
                    top: 5, left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                      child: Text("${item['chapters'] ?? '1'} Ep", style: const TextStyle(fontSize: 8, color: Colors.white)),
                    ),
                  ),
                  // Badge VIEWS (Kanan Atas)
                  Positioned(
                    top: 5, right: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                      child: Text(item['views'] ?? '0', style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(item['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white)),
        ],
      ),
    );
  }
}
