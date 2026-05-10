// lib/ui/tv/tv_detail.dart

import 'package:flutter/material.dart';

class TvDetail extends StatelessWidget {
  final String dramaId;
  final String platform;

  const TvDetail({
    super.key,
    required this.dramaId,
    required this.platform,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'TV Detail Screen\nID: $dramaId\nPlatform: $platform',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
