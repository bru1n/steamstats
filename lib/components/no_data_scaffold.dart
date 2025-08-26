import 'package:flutter/material.dart';
import 'package:steam_api_app/components/my_drawer.dart';

class NoDataScaffold extends StatelessWidget {
  final String title;
  final dynamic Function() refreshFunction;
  final String description;

  const NoDataScaffold({
    super.key,
    required this.title,
    required this.refreshFunction,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              refreshFunction();
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      drawerEdgeDragWidth: 16,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No Data =(',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
