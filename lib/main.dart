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
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const MainNavigation());
  }
}
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override State<MainNavigation> createState() => _MainNavigationState();
}
class _MainNavigationState extends State<MainNavigation> {
  int _idx = 0;
  final _p = [const HomePage(), const Center(child: Text("Halaman Unduhan")), const AccountPage()];
  void _exit() {
    showDialog(context: context, builder: (c) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text("Keluar"), content: const Text("Hapus cache dan keluar?"), actions: [
      TextButton(onPressed: () => Navigator.pop(c), child: const Text("Batal")),
      ElevatedButton(onPressed: () async { final d = await getTemporaryDirectory(); if (d.existsSync()) d.deleteSync(recursive: true); SystemNavigator.pop(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Ya"))
    ]));
  }
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return PopScope(canPop: false, onPopInvokedWithResult: (d, r) { if(!d) _exit(); }, child: Scaffold(
      body: Row(children: [
        if (isT) Container(width: 70, color: const Color(0xFF161B22), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(icon: Icon(Icons.home, color: _idx==0?Colors.blue:Colors.grey), onPressed: ()=>setState(()=>_idx=0)), const SizedBox(height: 30), IconButton(icon: Icon(Icons.person, color: _idx==2?Colors.blue:Colors.grey), onPressed: ()=>setState(()=>_idx=2))])),
        Expanded(child: IndexedStack(index: _idx, children: _p)),
      ]),
      bottomNavigationBar: isT ? null : BottomNavigationBar(currentIndex: _idx, onTap: (i)=>setState(()=>_idx=i), backgroundColor: const Color(0xFF161B22), selectedItemColor: Colors.blueAccent, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"), BottomNavigationBarItem(icon: Icon(Icons.download), label: "UNDUHAN"), BottomNavigationBarItem(icon: Icon(Icons.person), label: "AKUN")]),
    ));
  }
}
