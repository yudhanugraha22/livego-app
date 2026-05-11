import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/mobile/mobile_home.dart';
import 'ui/tv/tv_home.dart';
void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const ProviderScope(child: LivegoApp())); }
class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override Widget build(BuildContext context) { return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const MainSwitcher()); }
}
class MainSwitcher extends StatefulWidget {
  const MainSwitcher({super.key});
  @override State<MainSwitcher> createState() => _MainSwitcherState();
}
class _MainSwitcherState extends State<MainSwitcher> {
  int _idx = 0;
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return isT ? TVHome() : MobileHome();
  }
}
