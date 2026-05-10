import 'package:flutter/material.dart';

class MobileHome extends StatelessWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Mobile Home',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
