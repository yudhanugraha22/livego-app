import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/mobile/mobile_home.dart';
import 'ui/tv/tv_home.dart';
import 'ui/account_screen.dart';
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
    if (isT) return TVHome();
    final _p = [MobileHome(), const Center(child: Text("Unduhan")), AccountScreen()];
    return Scaffold(body: IndexedStack(index: _idx, children: _p), bottomNavigationBar: BottomNavigationBar(currentIndex: _idx, onTap: (i)=>setState(()=>_idx=i), backgroundColor: const Color(0xFF161B22), selectedItemColor: const Color(0xFF00D9FF), items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"), BottomNavigationBarItem(icon: Icon(Icons.download), label: "UNDUHAN"), BottomNavigationBarItem(icon: Icon(Icons.person), label: "AKUN")]));
  }
}
