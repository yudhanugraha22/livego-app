// lib/ui/mobile/mobile_player.dart

import 'package:flutter/material.dart';

class MobilePlayer extends StatelessWidget {
  final String dramaId;
  final String episodeId;
  final String platform;

  const MobilePlayer({
    super.key,
    required this.dramaId,
    required this.episodeId,
    required this.platform,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Mobile Video Player\nEpisode ID: $episodeId\nPlatform: $platform',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
