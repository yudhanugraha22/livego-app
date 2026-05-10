// lib/ui/tv/tv_player.dart

import 'package:flutter/material.dart';

class TvPlayer extends StatelessWidget {
  final String dramaId;
  final String episodeId;
  final String platform;

  const TvPlayer({
    super.key,
    required this.dramaId,
    required this.episodeId,
    required this.platform,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'TV Video Player Fullscreen\nEpisode ID: $episodeId\nPlatform: $platform',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
