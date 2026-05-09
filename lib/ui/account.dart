import 'package:flutter/material.dart';
import 'widgets.dart';
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0D1117), body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20)), child: const Row(children: [CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.person, color: Colors.white)), SizedBox(width: 15), Text("User Penggemar", style: TextStyle(fontWeight: FontWeight.bold))])),
      const SizedBox(height: 25),
      TVButton(onTap: (){}, child: const ListTile(leading: Icon(Icons.settings), title: Text("Pengaturan"))),
    ]));
  }
}
