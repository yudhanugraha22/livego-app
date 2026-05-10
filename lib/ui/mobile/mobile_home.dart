// lib/ui/mobile/mobile_home.dart

import 'package:flutter/material.dart';

class MobileHome extends StatelessWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LiveGo Mobile'),
        backgroundColor: const Color(0xFF0F121D),
      ),
      body: const Center(
        child: Text(
          'Mobile Home Screen\n(Under Development)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
