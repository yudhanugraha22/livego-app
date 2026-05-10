import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MobilePlayer extends StatelessWidget {
  final VideoPlayerController controller;
  final String title;
  final VoidCallback onToggle;
  const MobilePlayer({super.key, required this.controller, required this.title, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Column(
        children: [
          AppBar(backgroundColor: Colors.transparent, title: Text(title, style: const TextStyle(fontSize: 14))),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.replay_10, size: 40, color: Colors.white), onPressed: () => controller.seekTo(controller.value.position - const Duration(seconds: 10))),
              const SizedBox(width: 20),
              TVButton( // Pakai TVButton agar kursor tetap aman di HP
                onTap: onToggle,
                child: Icon(controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 80, color: Colors.white)
              ),
              const SizedBox(width: 20),
              IconButton(icon: const Icon(Icons.forward_10, size: 40, color: Colors.white), onPressed: () => controller.seekTo(controller.value.position + const Duration(seconds: 10))),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: VideoProgressIndicator(controller, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// Re-import local for TVButton context
class TVButton extends StatelessWidget {
  final Widget child; final VoidCallback onTap;
  const TVButton({super.key, required this.child, required this.onTap});
  @override Widget build(BuildContext context) { return GestureDetector(onTap: onTap, child: child); }
}
