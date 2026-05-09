import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'ui/home.dart';
import 'ui/account.dart';

void main() => runApp(const LivegoApp());

class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        primaryColor: const Color(0xFF8B5CF6),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const HomePage(), const Center(child: Text("Halaman Unduhan")), const AccountPage()];

  // FUNGSI PEMBERSIH CACHE & KELUAR
  Future<void> _clearAndExit() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) { cacheDir.deleteSync(recursive: true); }
      SystemNavigator.pop(); // Perintah keluar aplikasi
    } catch (e) {
      SystemNavigator.pop();
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("Keluar Aplikasi", style: TextStyle(color: Colors.blueAccent)),
        content: const Text("Ingin keluar dan bersihkan cache aplikasi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: _clearAndExit, 
            child: const Text("Ya, Keluar")
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (did, res) { if (!did) _showExitDialog(); },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: const Color(0xFF161B22),
          selectedItemColor: Colors.blueAccent,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "HOME"),
            BottomNavigationBarItem(icon: Icon(Icons.download), label: "UNDUHAN"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "AKUN"),
          ],
        ),
      ),
    );
  }
}
