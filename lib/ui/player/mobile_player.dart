import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MobilePlayer extends StatelessWidget {
  final VideoPlayerController v; final String title; final VoidCallback onToggle;
  const MobilePlayer({super.key, required this.v, required this.title, required this.onToggle});

  @override Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Column(children: [
        AppBar(backgroundColor: Colors.transparent, title: Text(title, style: const TextStyle(fontSize: 14))),
        const Spacer(),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: const Icon(Icons.replay_10, size: 40), onPressed: () => v.seekTo(v.value.position - const Duration(seconds: 10))),
          IconButton(icon: Icon(v.value.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 80), onPressed: onToggle),
          IconButton(icon: const Icon(Icons.forward_10, size: 40), onPressed: () => v.seekTo(v.value.position + const Duration(seconds: 10))),
        ]),
        const Spacer(),
        Padding(padding: const EdgeInsets.all(20), child: VideoProgressIndicator(v, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.redAccent))),
      ]),
    );
  }
}
