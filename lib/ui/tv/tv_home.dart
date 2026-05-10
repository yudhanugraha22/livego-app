import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/drama_model.dart';
import '../../data/repositories/drama_repository.dart';
import '../widgets/tv_sidebar_item.dart';
import 'tv_detail.dart';
import 'tv_history.dart';
import 'tv_settings.dart';

class TvHome extends StatefulWidget {
  const TvHome({super.key});

  @override
  State<TvHome> createState() => _TvHomeState();
}

class _TvHomeState extends State<TvHome> {
  final DramaRepository _repository = DramaRepository();
  List<DramaModel> _dramas = [];
  bool _isLoading = true;

  // State Navigasi & Fokus
  int _selectedMenuIndex = 0; // Default: Home (Index 0)
  int _focusedGridIndex = 0;
  final FocusNode _gridFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadDramas();
  }

  Future<void> _loadDramas() async {
    final data = await _repository.getPopularDramas();
    setState(() {
      _dramas = data;
      _isLoading = false;
    });
  }

  void _onMenuSelected(int index) {
    setState(() {
      _selectedMenuIndex = index;
    });

    // Navigasi menu berdasarkan index
    switch (index) {
      case 0: // Home
        _loadDramas();
        break;
      case 2: // Continue Watching (Riwayat)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TvHistory()),
        );
        break;
      case 5: // Settings / Profile (Sementara kita satukan ke Settings)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TvSettings()),
        );
        break;
      default:
        // Menu lainnya bisa disesuaikan nanti
        break;
    }
  }

  // Pindah fokus dari sidebar ke area grid drama (konten utama)
  void _focusContentGrid() {
    if (_dramas.isNotEmpty) {
      _gridFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _gridFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090615),
      body: Row(
        children: [
          // ================= SIDEBAR KIRI PREMIUM =================
          Container(
            width: 240,
            color: const Color(0xFF0D0A1E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Logo App (Atas)
                Padding(
                  padding: const EdgeInsets.only(top: 28.0, left: 20.0, bottom: 20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D9FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "LIVEGO",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 16),

                // 2. Daftar Menu Utama Sidebar (Sesuai Blueprint Anda)
                Expanded(
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      TvSidebarItem(
                        icon: Icons.home,
                        label: "Home",
                        isSelected: _selectedMenuIndex == 0,
                        onTap: () => _onMenuSelected(0),
                        onRequestFocusContent: _focusContentGrid,
                      ),
                      TvSidebarItem(
                        icon: Icons.download,
                        label: "Download",
                        isSelected: _selectedMenuIndex == 1,
                        onTap: () => _onMenuSelected(1),
                        onRequestFocusContent: _focusContentGrid,
                      ),
                      TvSidebarItem(
                        icon: Icons.history,
                        label: "Continue Watching",
                        isSelected: _selectedMenuIndex == 2,
                        onTap: () => _onMenuSelected(2),
                        onRequestFocusContent: _focusContentGrid,
                      ),
                      TvSidebarItem(
                        icon: Icons.favorite,
                        label: "Favorit",
                        isSelected: _selectedMenuIndex == 3,
                        onTap: () => _onMenuSelected(3),
                        onRequestFocusContent: _focusContentGrid,
                      ),
                      TvSidebarItem(
                        icon: Icons.person,
                        label: "Profile",
                        isSelected: _selectedMenuIndex == 4,
                        onTap: () => _onMenuSelected(4),
                        onRequestFocusContent: _focusContentGrid,
                      ),
                      TvSidebarItem(
                        icon: Icons.search,
                        label: "Search",
                        isSelected: _selectedMenuIndex == 5,
                        onTap: () => _onMenuSelected(5),
                        onRequestFocusContent: _focusContentGrid,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= AREA KONTEN UTAMA KANAN =================
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "DRAMA POPULER",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Focus(
                            focusNode: _gridFocusNode,
                            onKeyEvent: (node, event) {
                              if (event is KeyDownEvent) {
                                // Jika di paling kiri grid, tekan kiri (←) untuk kembali ke sidebar
                                if (event.logicalKey == LogicalKeyboardKey.arrowLeft && (_focusedGridIndex % 3 == 0)) {
                                  // Kosongkan fokus grid agar berpindah kembali ke item sidebar
                                  FocusScope.of(context).previousFocus();
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.4,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _dramas.length,
                              itemBuilder: (context, index) {
                                final drama = _dramas[index];
                                final isFocused = _gridFocusNode.hasFocus && _focusedGridIndex == index;

                                return InkWell(
                                  onFocusChange: (hasFocus) {
                                    if (hasFocus) {
                                      setState(() {
                                        _focusedGridIndex = index;
                                      });
                                    }
                                  },
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TvDetail(drama: drama),
                                      ),
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1B30),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isFocused ? const Color(0xFF00D9FF) : Colors.white10,
                                        width: isFocused ? 2.5 : 1,
                                      ),
                                      boxShadow: isFocused
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF00D9FF).withOpacity(0.3),
                                                blurRadius: 12,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: Stack(
                                        children: [
                                          // Placeholder Poster / Neon Background
                                          Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Color(0xFF1E1B30), Color(0xFF0D0A1E)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              color: Colors.black87,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    drama.title,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "Platform: ${drama.platform.toUpperCase()}",
                                                    style: const TextStyle(
                                                      color: Color(0xFF00D9FF),
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
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
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
