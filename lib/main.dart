import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'ui/home.dart';
import 'ui/account.dart';

void main() => runApp(const LivegoApp());

class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF000000), primaryColor: const Color(0xFF8B5CF6)),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _idx = 0;
  final _pages = [const HomePage(), const Center(child: Text("Unduhan")), const AccountPage()];

  void _showExitDialog() {
    showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: const Text("Keluar Aplikasi", style: TextStyle(color: Colors.blueAccent)),
      content: const Text("Yakin ingin keluar dan bersihkan cache?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Batal")),
        ElevatedButton(onPressed: () async {
          final dir = await getTemporaryDirectory();
          if (dir.existsSync()) dir.deleteSync(recursive: true);
          SystemNavigator.pop();
        }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Ya, Keluar")),
      ],
    ));
  }

  @override Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (did, res) { if(!did) _showExitDialog(); },
      child: Scaffold(
        body: IndexedStack(index: _idx, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _idx, onTap: (i)=>setState(()=>_idx=i),
          backgroundColor: const Color(0xFF161B22), selectedItemColor: Colors.blueAccent,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
            BottomNavigationBarItem(icon: Icon(Icons.download), label: "UNDUHAN"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "AKUN"),
          ],
        ),
      ),
    );
  }
}
