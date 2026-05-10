import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/drama_model.dart';
import '../../data/repositories/drama_repository.dart';

class TvHome extends StatefulWidget {
  const TvHome({super.key});

  @override
  State<TvHome> createState() => _TvHomeState();
}

class _TvHomeState extends State<TvHome> {
  final DramaRepository _repository = DramaRepository();
  List<DramaModel> _dramas = [];
  bool _isLoading = true;
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dramas = await _repository.getDramas();
    setState(() {
      _dramas = dramas;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090615), // Sangat gelap, pas untuk TV besar
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
              ),
            )
          : Row(
              children: [
                // 1. Sidebar Navigasi Kiri (Khas Android TV)
                Container(
                  width: 80,
                  color: const Color(0xFF0D0A1E),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.home, color: Color(0xFF00D9FF), size: 30),
                        onPressed: () {},
                      ),
                      const SizedBox(height: 32),
                      IconButton(
                        icon: const Icon(Icons.tv, color: Colors.white38, size: 28),
                        onPressed: () {},
                      ),
                      const SizedBox(height: 32),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.white38, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // 2. Konten Utama Kanan
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Logo Premium
                          const Row(
                            children: [
                              Text(
                                'LIVEGO',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.black,
                                  letterSpacing: 3,
                                  color: Color(0xFF00D9FF),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'TV BOOTCAMP',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white38,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Daftar Drama Baris Horizontal
                          const Text(
                            'Koleksi Drama China Terpopuler',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            height: 280,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _dramas.length,
                              itemBuilder: (context, index) {
                                final drama = _dramas[index];
                                final isFocused = _focusedIndex == index;

                                return InkWell(
                                  onFocusChange: (hasFocus) {
                                    if (hasFocus) {
                                      setState(() {
                                        _focusedIndex = index;
                                      });
                                    }
                                  },
                                  onTap: () {},
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: isFocused ? 190 : 170,
                                    margin: const EdgeInsets.only(right: 24),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isFocused
                                            ? const Color(0xFF00D9FF)
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: isFocused
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF00D9FF).withOpacity(0.4),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: drama.poster,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.85),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 16,
                                            left: 16,
                                            right: 16,
                                            child: Text(
                                              drama.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
