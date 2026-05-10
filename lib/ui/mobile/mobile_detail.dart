// lib/ui/mobile/mobile_detail.dart

import 'package:flutter/material.dart';

class MobileDetail extends StatelessWidget {
  final String dramaId;
  final String platform;

  const MobileDetail({
    super.key,
    required this.dramaId,
    required this.platform,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Drama'),
        backgroundColor: const Color(0xFF0F121D),
      ),
      body: Center(
        child: Text(
          'Mobile Detail Screen\nID: $dramaId\nPlatform: $platform',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
