import 'package:flutter/material.dart';
import 'widgets.dart';
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(body: ListView(padding: const EdgeInsets.all(15), children: [
      const SizedBox(height: 50),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(25)), child: const ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF8B5CF6), child: Icon(Icons.play_arrow, color: Colors.white)), title: Text("User Penggemar"), subtitle: Text("Akun CineFlow"))),
      const SizedBox(height: 20),
      TVButton(onTap: (){}, child: const ListTile(leading: Icon(Icons.history), title: Text("Riwayat"))),
      TVButton(onTap: (){}, child: const ListTile(leading: Icon(Icons.favorite), title: Text("Favorit"))),
    ]));
  }
}
