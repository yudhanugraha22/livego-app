import 'package:flutter/material.dart';
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
  @override Widget build(BuildContext context) {
    bool isT = MediaQuery.of(context).size.width > 900;
    return Scaffold(body: Row(children: [
      if (isT) Container(width: 70, color: const Color(0xFF161B22), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(icon: Icon(Icons.home, color: _idx==0?Colors.blue:Colors.grey), onPressed: ()=>setState(()=>_idx=0)),
        const SizedBox(height: 30),
        IconButton(icon: Icon(Icons.person, color: _idx==2?Colors.blue:Colors.grey), onPressed: ()=>setState(()=>_idx=2))
      ])),
      Expanded(child: IndexedStack(index: _idx, children: [HomePage(), const Center(child: Text("Halaman Unduhan")), AccountPage()])),
    ]), bottomNavigationBar: isT ? null : BottomNavigationBar(currentIndex: _idx, onTap: (i)=>setState(()=>_idx=i), backgroundColor: const Color(0xFF161B22), selectedItemColor: Colors.blueAccent, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"), BottomNavigationBarItem(icon: Icon(Icons.download), label: "UNDUHAN"), BottomNavigationBarItem(icon: Icon(Icons.person), label: "AKUN")]));
  }
}
