import 'package:flutter/material.dart';
import 'ui/home.dart';
import 'ui/account.dart';

void main() => runApp(const LivegoApp());

class LivegoApp extends StatelessWidget {
  const LivegoApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        primaryColor: const Color(0xFF8B5CF6)
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
  int _idx = 0;
  final _pages = [const HomePage(), const Center(child: Text("Halaman Unduhan")), const AccountPage()];

  @override Widget build(BuildContext context) {
    bool isTV = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      body: Row(children: [
        if (isTV) Container(
          width: 70, color: const Color(0xFF161B22),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _sideBtn(0, Icons.home), const SizedBox(height: 30),
            _sideBtn(1, Icons.download), const SizedBox(height: 30),
            _sideBtn(2, Icons.person),
          ]),
        ),
        Expanded(child: IndexedStack(index: _idx, children: _pages)),
      ]),
      bottomNavigationBar: isTV ? null : BottomNavigationBar(
        currentIndex: _idx, onTap: (i)=>setState(()=>_idx=i),
        backgroundColor: const Color(0xFF161B22), selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: "UNDUHAN"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "AKUN"),
        ],
      ),
    );
  }
  Widget _sideBtn(int i, IconData ico) => IconButton(icon: Icon(ico, color: _idx == i ? Colors.blueAccent : Colors.grey, size: 28), onPressed: () => setState(() => _idx = i));
}
