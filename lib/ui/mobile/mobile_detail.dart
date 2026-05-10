// lib/ui/mobile/mobile_detail.dart

import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../data/models/drama_model.dart';
import '../../data/repositories/drama_repository.dart';
import '../../routes/app_routes.dart';

class MobileDetail extends StatefulWidget {
  final String dramaId;
  final String platform;

  const MobileDetail({
    super.key,
    required this.dramaId,
    required this.platform,
  });

  @override
  State<MobileDetail> createState() => _MobileDetailState();
}

class _MobileDetailState extends State<MobileDetail> {
  late final DramaRepository _repository;
  DramaModel? _drama;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = DramaRepository(ApiService());
    _loadDramaDetail();
  }

  Future<void> _loadDramaDetail() async {
    setState(() => _isLoading = true);
    final detail = await _repository.getDramaDetail(widget.dramaId, widget.platform);
    setState(() {
      _drama = detail;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070D),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF)))
          : _drama == null
              ? _buildErrorState()
              : CustomScrollView(
                  slivers: [
                    // 1. Header Banner/Poster Atas
                    SliverAppBar(
                      expandedHeight: 300,
                      pinned: true,
                      backgroundColor: const Color(0xFF05070D),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.network(
                          _drama!.banner ?? _drama!.poster,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // 2. Konten Informasi Drama
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Judul Drama
                            Text(
                              _drama!.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Badge Platform & Info
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6), // Purple Glow
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _drama!.platform.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  _drama!.rating.toString(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _drama!.status,
                                  style: const TextStyle(color: Color(0xFF00D9FF), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Sinopsis/Deskripsi
                            const Text(
                              'Sinopsis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _drama!.description.isEmpty ? 'Tidak ada sinopsis.' : _drama!.description,
                              style: const TextStyle(color: Color(0xFF94A3B8), height: 1.5),
                            ),
                            const SizedBox(height: 24),

                            // Daftar Episode
                            const Text(
                              'Daftar Episode',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Grid Episode
                            _buildEpisodeGrid(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEpisodeGrid() {
    final total = _drama!.totalEpisodes;
    if (total == 0) {
      return const Text('Episode belum tersedia.', style: TextStyle(color: Colors.grey));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: total,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final epNum = index + 1;
        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.player,
              arguments: {
                'drama_id': _drama!.id,
                'episode_id': epNum.toString(), // Kita asumsikan id episodenya berbasis nomor untuk saat ini
                'platform': _drama!.platform,
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F121D),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            alignment: Alignment.center,
            child: Text(
              '$epNum',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Gagal memuat detail drama.', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadDramaDetail,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
