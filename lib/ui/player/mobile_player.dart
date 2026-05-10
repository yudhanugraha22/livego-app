import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class MobilePlayer extends StatelessWidget {
  final VideoPlayerController v; final String title; final VoidCallback onToggle;
  const MobilePlayer({super.key, required this.v, required this.title, required this.onToggle});
  @override Widget build(BuildContext context) {
    return Container(color: Colors.black45, child: Column(children: [
      AppBar(backgroundColor: Colors.transparent, title: Text(title)),
      const Spacer(),
      IconButton(icon: Icon(v.value.isPlaying?Icons.pause_circle:Icons.play_circle, size: 80, color: Colors.white60), onPressed: onToggle),
      const Spacer(),
      VideoProgressIndicator(v, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.redAccent)),
    ]));
  }
}
