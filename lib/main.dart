import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/mobile/mobile_home.dart';
import 'ui/mobile/account_screen.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const ProviderScope(child: LivegoApp())); }
class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override Widget build(BuildContext context) { return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const MainNavigation()); }
}
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override State<MainNavigation> createState() => _MainNavigationState();
}
class _MainNavigationState extends State<MainNavigation> {
  int _idx = 0;
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    final pages = [const MobileHome(), const Center(child: Text("Unduhan")), const AccountScreen()];
    return Scaffold(
      body: Row(children: [
        if (isT) Container(width: 80, color: const Color(0xFF161B22), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ IconButton(icon: Icon(Icons.home, color: _idx==0?const Color(0xFF00D9FF):Colors.grey), onPressed: ()=>setState(()=>_idx=0)), const SizedBox(height: 30), IconButton(icon: Icon(Icons.person, color: _idx==2?const Color(0xFF00D9FF):Colors.grey), onPressed: ()=>setState(()=>_idx=2)) ])),
        Expanded(child: IndexedStack(index: _idx, children: pages)),
      ]),
      bottomNavigationBar: isT ? null : BottomNavigationBar(currentIndex: _idx, onTap: (i)=>setState(()=>_idx=i), backgroundColor: const Color(0xFF161B22), selectedItemColor: const Color(0xFF00D9FF), unselectedItemColor: Colors.grey, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"), BottomNavigationBarItem(icon: Icon(Icons.download), label: "UNDUHAN"), BottomNavigationBarItem(icon: Icon(Icons.person), label: "AKUN")]),
    );
  }
}
