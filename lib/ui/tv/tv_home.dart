import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../shared/widgets.dart';

class TVHome extends ConsumerWidget {
  const TVHome({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dramas = ref.watch(homeDataProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(children: [
        Container(width: 70, color: const Color(0xFF161B22), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.home, color: Colors.blueAccent), SizedBox(height: 30), Icon(Icons.person, color: Colors.grey)])),
        Expanded(child: dramas.when(
          data: (list) => GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.65, mainAxisSpacing: 10, crossAxisSpacing: 10),
            itemCount: list.length,
            itemBuilder: (c, i) => TVButton(onTap: (){}, child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(list[i]['cover'], fit: BoxFit.cover))),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const Center(child: Text("Error API")),
        ))
      ]),
    );
  }
}
