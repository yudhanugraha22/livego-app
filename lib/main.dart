import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/mobile/mobile_home.dart';
import 'ui/tv/tv_home.dart';
void main() => runApp(const ProviderScope(child: LivegoApp()));
class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const MainSwitcher());
  }
}
class MainSwitcher extends StatelessWidget {
  const MainSwitcher({super.key});
  @override Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 900 ? const TVHome() : const MobileHome();
  }
}
