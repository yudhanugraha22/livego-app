// lib/ui/tv/tv_home.dart

import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../data/models/drama_model.dart';
import '../../data/repositories/drama_repository.dart';
import '../../routes/app_routes.dart';

class TvHome extends StatefulWidget {
  const TvHome({super.key});

  @override
  State<TvHome> createState() => _TvHomeState();
}

class _TvHomeState extends State<TvHome> {
  late final DramaRepository _repository;
  List<DramaModel> _banners = [];
  List<DramaModel> _dramas = [];
  bool _isLoading = true;
  int _focusedMenuIndex = 0;

  @override
  void initState() {
    super.initState();
    _repository = DramaRepository(ApiService());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final bannerData = await _repository.getBanners();
      final dramaData = await _repository.getHomeContent(category: 'all');
      
      setState(() {
        _banners = bannerData;
        _dramas = dramaData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Sidebar Navigasi Kiri (D-Pad Friendly)
          _buildTvSidebar(),

          // 2. Konten Utama TV
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF)))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sorotan Utama (Hero Banner)
                        if (_banners.isNotEmpty) _buildTvHeroBanner(),
                        
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                          child: Text(
                            'Koleksi Drama Populer',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Carousel List Horizontal
                        _buildTvDramaRow(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTvSidebar() {
    final List<IconData> menuIcons = [Icons.home, Icons.search, Icons.favorite, Icons.settings];
    
    return Container(
      width: 90,
      color: const Color(0xFF0F121D),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(menuIcons.length, (index) {
          final isSelected = _focusedMenuIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  setState(() => _focusedMenuIndex = index);
                }
              },
              child: Builder(
                builder: (context) {
                  final hasFocus = Focus.of(context).hasFocus;
                  return Icon(
                    menuIcons[index],
                    size: 32,
                    color: hasFocus 
                        ? const Color(0xFF00D9FF) 
                        : (isSelected ? const Color(0xFF8B5CF6) : Colors.grey),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTvHeroBanner() {
    final hero = _banners.first;
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(hero.banner ?? hero.poster),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFF05070D),
              Colors.black.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(40.0),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00D9FF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                hero.platform.toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hero.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 500,
              child: Text(
                hero.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTvDramaRow() {
    if (_dramas.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text('Tidak ada drama aktif.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: _dramas.length,
        itemBuilder: (context, index) {
          final drama = _dramas[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Focus(
              onKey: (node, event) {
                // Menangani eksekusi tombol Enter/OK pada remote TV
                if (event.logicalKey.keyLabel == 'Select' || event.logicalKey.keyLabel == 'Enter') {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.detail,
                    arguments: {'drama_id': drama.id, 'platform': drama.platform},
                  );
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Builder(
                builder: (context) {
                  final hasFocus = Focus.of(context).hasFocus;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: hasFocus ? 150 : 130,
                    height: hasFocus ? 220 : 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasFocus ? const Color(0xFF00D9FF) : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: hasFocus
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00D9FF).withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(drama.poster, fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Text(
                              drama.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
