import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  final String title;
  final Widget route;
  final Icon icon;

  const DrawerTile({
    super.key,
    required this.title,
    required this.route,
    required this.icon,
  });

  void navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);

    Navigator.popUntil(context, (route) {
      return route.settings.name == page.runtimeType.toString() || route.isFirst;
    });

    if (ModalRoute.of(context)?.settings.name != page.runtimeType.toString()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page,
          settings: RouteSettings(name: page.runtimeType.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 18),
        ),
        leading: icon,
        onTap: () {
          navigateTo(context, route);
        },
      ),
    );
  }
}
