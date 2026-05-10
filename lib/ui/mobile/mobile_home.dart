// lib/ui/mobile/mobile_home.dart

import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../data/models/drama_model.dart';
import '../../data/repositories/drama_repository.dart';
import '../../routes/app_routes.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  late final DramaRepository _repository;
  List<DramaModel> _banners = [];
  List<DramaModel> _dramas = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'name': 'Semua'},
    {'id': 'drama', 'name': 'Drama'},
    {'id': 'romance', 'name': 'Romantis'},
    {'id': 'action', 'name': 'Aksi'},
  ];

  @override
  void initState() {
    super.initState();
    // Menggunakan ApiService untuk menyuplai repository
    _repository = DramaRepository(ApiService());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final bannerData = await _repository.getBanners();
      final dramaData = await _repository.getHomeContent(category: _selectedCategory);
      
      setState(() {
        _banners = bannerData;
        _dramas = dramaData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CINEFLOW',
          style: TextStyle(
            color: Color(0xFF00D9FF), // Cyan Neon
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: const Color(0xFF05070D),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implementasi Search
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF00D9FF),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Bagian Banner Slider (Jika ada data banner)
                    if (_banners.isNotEmpty) _buildBannerSlider(),

                    // 2. Tab Kategori Menu
                    _buildCategoryTabs(),

                    // 3. Daftar Grid Drama
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      child: Text('Rekomendasi Untukmu'),
                    ),
                    _buildDramaGrid(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBannerSlider() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: _banners.length,
        itemBuilder: (context, index) {
          final drama = _banners[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.detail,
              arguments: {'drama_id': drama.id, 'platform': drama.platform},
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(drama.banner ?? drama.poster),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.bottomLeft,
                child: Text(
                  drama.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['id'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: ChoiceChip(
              label: Text(cat['name']!),
              selected: isSelected,
              selectedColor: const Color(0xFF00D9FF),
              backgroundColor: const Color(0xFF0F121D),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF05070D) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = cat['id']!;
                  });
                  _loadData();
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDramaGrid() {
    if (_dramas.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Tidak ada konten yang tersedia.\nCoba periksa Kelola Sumber Data Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _dramas.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final drama = _dramas[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.detail,
              arguments: {'drama_id': drama.id, 'platform': drama.platform},
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(drama.poster),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  drama.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  drama.platform.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF8B5CF6), // Purple Glow
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
