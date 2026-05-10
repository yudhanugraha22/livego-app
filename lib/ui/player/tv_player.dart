import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../shared/widgets.dart';

class TVPlayer extends StatelessWidget {
  final VideoPlayerController v; final String title;
  const TVPlayer({super.key, required this.v, required this.title});

  @override Widget build(BuildContext context) {
    return Positioned(
      bottom: 30, left: 60, right: 60,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2A4F).withOpacity(0.9),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2.5),
        ),
        child: Column(children: [
          VideoProgressIndicator(v, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.pinkAccent)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            const Icon(Icons.skip_previous, color: Colors.white70),
            TVButton(onTap: () => v.value.isPlaying ? v.pause() : v.play(), child: Icon(v.value.isPlaying ? Icons.pause : Icons.play_arrow, size: 50, color: Colors.white)),
            const Icon(Icons.skip_next, color: Colors.white70),
            const Text("1080P", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const Icon(Icons.list, color: Colors.white70),
          ])
        ]),
      ),
    );
  }
}
