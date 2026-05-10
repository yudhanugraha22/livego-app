// lib/ui/tv/tv_detail.dart

import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../data/models/drama_model.dart';
import '../../data/repositories/drama_repository.dart';
import '../../routes/app_routes.dart';

class TvDetail extends StatefulWidget {
  final String dramaId;
  final String platform;

  const TvDetail({
    super.key,
    required this.dramaId,
    required this.platform,
  });

  @override
  State<TvDetail> createState() => _TvDetailState();
}

class _TvDetailState extends State<TvDetail> {
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
              ? _buildTvErrorState()
              : Row(
                  children: [
                    // KIRI: Detail Info Drama & Poster Besar
                    Expanded(
                      flex: 4,
                      child: _buildLeftPanel(),
                    ),

                    // KANAN: Daftar Episode (Scrollable List D-pad)
                    Expanded(
                      flex: 3,
                      child: _buildRightPanel(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(_drama!.banner ?? _drama!.poster),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.85),
            BlendMode.multiply,
          ),
        ),
      ),
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tombol Kembali
          BackButton(
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            _drama!.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D9FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _drama!.platform.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                _drama!.rating.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Text(
                _drama!.status,
                style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _drama!.description.isEmpty ? 'Tidak ada sinopsis.' : _drama!.description,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.6),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    final total = _drama!.totalEpisodes;
    return Container(
      color: const Color(0xFF0F121D),
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PILIH EPISODE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D9FF),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: total == 0
                ? const Center(child: Text('Episode tidak ditemukan.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: total,
                    itemBuilder: (context, index) {
                      final epNum = index + 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Focus(
                          onKey: (node, event) {
                            if (event.logicalKey.keyLabel == 'Select' || event.logicalKey.keyLabel == 'Enter') {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.player,
                                arguments: {
                                  'drama_id': _drama!.id,
                                  'episode_id': epNum.toString(),
                                  'platform': _drama!.platform,
                                },
                              );
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: Builder(
                            builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: hasFocus ? const Color(0xFF00D9FF) : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: hasFocus
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF00D9FF).withOpacity(0.4),
                                            blurRadius: 10,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  'Episode $epNum',
                                  style: TextStyle(
                                    color: hasFocus ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTvErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Gagal mengambil data drama dari server.', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDramaDetail,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
