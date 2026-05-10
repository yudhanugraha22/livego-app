import 'package:flutter/material.dart';

class TVHome extends StatelessWidget {
  const TVHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'TV Home',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
