import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mobile/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LivegoApp()));
}

class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiveGO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MobileHome(),
    );
  }
}
